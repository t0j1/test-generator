class TestSheetsController < ApplicationController
  before_action :set_test_sheet, only: [:show, :preview, :mark_printed, :destroy]

  # GET / (root_path)
  # キオスク待機画面（ランディング）
  def landing
    # 何もしない（静的HTML表示）
  end

  # GET /test_sheets/css_test
  # CSS デバッグページ
  def css_test
    # 何もしない（CSS動作確認用の静的HTML表示）
  end

  # GET /test_sheets/step1
  # Step 1: 科目選択
  def step1
    @subjects = Subject.ordered
  end

  # GET /test_sheets/step2
  # Step 2: 単元+設定選択
  def step2
    @subject = Subject.find_by(id: params[:subject_id])
    unless @subject
      redirect_to step1_test_sheets_path, alert: '科目を選択してください'
      return
    end
    
    @units = @subject.units.ordered
    @test_sheet = TestSheet.new(subject_id: @subject.id)
    
    # デバッグモード（?debug=1を付けるとデバッグビューを表示）
    if params[:debug] == '1'
      render :step2_debug
      return
    end
    
    # ミニマルモード（?minimal=1を付けるとシンプルなビューを表示）
    if params[:minimal] == '1'
      render :step2_minimal
      return
    end
    
    # プレーンHTMLモード（?plain=1を付けるとプレーンHTMLを表示）
    if params[:plain] == '1'
      render :step2_plain, layout: false
      return
    end
  rescue StandardError => e
    Rails.logger.error "Step2 Error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to step1_test_sheets_path, alert: "エラーが発生しました: #{e.message}"
  end

  # POST /test_sheets/step2_submit
  # Step 2: フォーム送信 → テスト生成 → Step 3へリダイレクト
  def step2_submit
    @test_sheet = TestSheet.new(test_sheet_params)
    
    if @test_sheet.save
      # 問題生成を実行
      begin
        @test_sheet.generate_questions!
        redirect_to test_sheet_path(@test_sheet), notice: 'テストを作成しました'
      rescue StandardError => e
        # 問題生成失敗時
        @test_sheet.destroy
        redirect_to step1_test_sheets_path, alert: "テスト作成に失敗しました: #{e.message}"
      end
    else
      # バリデーションエラー
      @subject = Subject.find_by(id: test_sheet_params[:subject_id])
      @units = @subject&.units&.ordered || []
      flash.now[:alert] = 'テスト作成に失敗しました'
      render :step2, status: :unprocessable_entity
    end
  end

  # GET /test_sheets/new
  # テスト作成画面（旧UI - 後方互換性のため残す）
  def new
    @test_sheet = TestSheet.new
    @subjects = Subject.ordered
  end

  # POST /test_sheets
  # テスト生成実行（旧UI用 - 後方互換性のため残す）
  def create
    @test_sheet = TestSheet.new(test_sheet_params)
    
    if @test_sheet.save
      # 問題生成を実行
      begin
        @test_sheet.generate_questions!
        redirect_to test_sheet_path(@test_sheet), notice: 'テストを作成しました'
      rescue StandardError => e
        # 問題生成失敗時
        @test_sheet.destroy
        redirect_to new_test_sheet_path, alert: "テスト作成に失敗しました: #{e.message}"
      end
    else
      # バリデーションエラー
      @subjects = Subject.ordered
      flash.now[:alert] = 'テスト作成に失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  # GET /test_sheets/:id
  # テスト表示画面（印刷用）
  def show
    @questions = @test_sheet.test_questions.includes(:question).order(:question_order)
  end

  # GET /test_sheets/:id/preview
  # 印刷プレビュー（showと同じだが、レイアウトを分ける場合に使用）
  def preview
    @questions = @test_sheet.test_questions.includes(:question).order(:question_order)
    render :show
  end

  # POST /test_sheets/:id/mark_printed
  # 印刷済みマーク
  def mark_printed
    @test_sheet.mark_as_printed!
    render json: { success: true, printed_at: @test_sheet.printed_at }
  rescue StandardError => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  # GET /test_sheets
  # テスト一覧（印刷履歴）
  def index
    @test_sheets = TestSheet.includes(:subject, :unit)
                             .order(created_at: :desc)
                             .page(params[:page])
                             .per(20)
  end

  # GET /test_sheets/history
  # 印刷履歴（indexのエイリアス）
  def history
    @test_sheets = TestSheet.includes(:subject, :unit)
                             .where.not(printed_at: nil)
                             .order(printed_at: :desc)
                             .page(params[:page])
                             .per(20)
    render :index
  end

  # DELETE /test_sheets/:id
  # テストシート削除
  def destroy
    @test_sheet.destroy
    redirect_to test_sheets_path, notice: 'テストを削除しました'
  rescue StandardError => e
    Rails.logger.error "Destroy Error: #{e.class} - #{e.message}"
    redirect_to test_sheets_path, alert: "削除に失敗しました: #{e.message}"
  end

  # GET /test_sheets/units_by_subject
  # AJAX: 科目IDから単元リストを取得
  def units_by_subject
    subject = Subject.find_by(id: params[:subject_id])
    
    unless subject
      render json: { error: '科目が見つかりません' }, status: :not_found
      return
    end

    units = subject.units.ordered.map do |unit|
      {
        id: unit.id,
        name: unit.name,
        grade: unit.grade,
        grade_label: "高#{unit.grade}",
        question_count: unit.question_count,
        question_counts_by_difficulty: unit.question_counts_by_difficulty
      }
    end

    render json: {
      subject_id: subject.id,
      subject_name: subject.name,
      units: units
    }
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # GET /test_sheets/available_questions
  # AJAX: 利用可能な問題数を取得
  def available_questions
    unit = Unit.find_by(id: params[:unit_id])
    
    unless unit
      render json: { error: '単元が見つかりません' }, status: :not_found
      return
    end

    difficulty = params[:difficulty].presence
    
    # 難易度指定がある場合
    if difficulty.present? && TestSheet::DIFFICULTIES.key?(difficulty.to_sym)
      # セキュリティのため、sendの代わりに明示的なcase文を使用
      count = case difficulty.to_sym
              when :easy
                unit.questions.difficulty_easy.count
              when :normal
                unit.questions.difficulty_normal.count
              when :hard
                unit.questions.difficulty_hard.count
              else
                unit.question_count
              end
      label = TestSheet::DIFFICULTY_LABELS[difficulty]
    else
      # ミックス（全難易度）
      count = unit.question_count
      label = TestSheet::DIFFICULTY_LABELS["mix"]
    end

    render json: {
      unit_id: unit.id,
      unit_name: unit.name,
      difficulty: difficulty || 'mix',
      difficulty_label: label,
      available_count: count,
      counts_by_difficulty: unit.question_counts_by_difficulty
    }
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_test_sheet
    @test_sheet = TestSheet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'テストが見つかりません'
  end

  def test_sheet_params
    params.require(:test_sheet).permit(
      :subject_id,
      :unit_id,
      :difficulty,
      :question_count,
      :include_hint,
      :include_answer,
      :separate_answer_sheet
    )
  end
end
