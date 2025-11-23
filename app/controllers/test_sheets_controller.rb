# frozen_string_literal: true

class TestSheetsController < ApplicationController
  before_action :set_test_sheet, only: %i[show preview mark_printed]

  # GET /test_sheets
  # テスト一覧（印刷履歴）
  def index
    @test_sheets = TestSheet.includes(:subject, :unit)
                            .order(created_at: :desc)
                            .page(params[:page])
                            .per(20)
  end

  # GET /test_sheets/:id
  # テスト表示画面（印刷用）
  def show
    @questions = @test_sheet.test_questions.includes(:question).order(:question_order)
  end

  # GET /test_sheets/new
  # テスト作成画面
  def new
    @test_sheet = TestSheet.new
    @subjects = Subject.ordered
  end

  # POST /test_sheets
  # テスト生成実行
  def create
    @test_sheet = TestSheet.new(test_sheet_params)

    if @test_sheet.save
      # 問題生成を実行
      begin
        @test_sheet.generate_questions!
        redirect_to test_sheet_path(@test_sheet), notice: "テストを作成しました"
      rescue StandardError => e
        # 問題生成失敗時
        @test_sheet.destroy
        redirect_to new_test_sheet_path, alert: "テスト作成に失敗しました: #{e.message}"
      end
    else
      # バリデーションエラー
      @subjects = Subject.ordered
      flash.now[:alert] = "テスト作成に失敗しました"
      render :new, status: :unprocessable_content
    end
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
    render json: { success: false, error: e.message }, status: :unprocessable_content
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

  # GET /test_sheets/available_questions
  # AJAX: 利用可能な問題数を取得
  def available_questions
    unit = Unit.find_by(id: params[:unit_id])

    unless unit
      render json: { error: "単元が見つかりません" }, status: :not_found
      return
    end

    difficulty = params[:difficulty].presence

    # 難易度指定がある場合
    if difficulty.present? && TestSheet::DIFFICULTIES.key?(difficulty.to_sym)
      count = unit.questions.send("difficulty_#{difficulty}").count
      label = TestSheet::DIFFICULTY_LABELS[difficulty]
    else
      # ミックス（全難易度）
      count = unit.question_count
      label = TestSheet::MIX_LABEL
    end

    render json: {
      unit_id: unit.id,
      unit_name: unit.name,
      difficulty: difficulty || "mix",
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
    redirect_to root_path, alert: "テストが見つかりません"
  end

  def test_sheet_params
    params.expect(
      test_sheet: %i[subject_id
                     unit_id
                     difficulty
                     question_count
                     include_hint
                     include_answer]
    )
  end
end
