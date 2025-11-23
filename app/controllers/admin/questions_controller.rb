require "csv"

module Admin
  class QuestionsController < ApplicationController
    layout "admin"
    before_action :set_question, only: [:show, :edit, :update, :destroy]
    before_action :set_filter_options, only: [:index, :new, :edit]

    def index
      @questions = Question.kept.includes(:subject, :unit)
      
      # 検索フィルター
      if params[:subject_id].present?
        @questions = @questions.where(subject_id: params[:subject_id])
      end
      
      if params[:unit_id].present?
        @questions = @questions.where(unit_id: params[:unit_id])
      end
      
      if params[:difficulty].present?
        @questions = @questions.where(difficulty: params[:difficulty])
      end
      
      if params[:question_type].present?
        @questions = @questions.where(question_type: params[:question_type])
      end
      
      # 検索キーワード
      if params[:keyword].present?
        keyword = "%#{params[:keyword]}%"
        @questions = @questions.where(
          "word LIKE ? OR meaning LIKE ? OR hint LIKE ?",
          keyword, keyword, keyword
        )
      end
      
      # ページネーション
      @questions = @questions.order(created_at: :desc).page(params[:page]).per(50)
    end

    def show
      # 詳細表示は不要なのでindexにリダイレクト
      redirect_to admin_questions_path
    end

    def new
      @question = Question.new
    end

    def create
      @question = Question.new(question_params)
      
      if @question.save
        redirect_to admin_questions_path, notice: "問題を作成しました"
      else
        set_filter_options
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      # set_question で@questionは設定済み
    end

    def update
      if @question.update(question_params)
        redirect_to admin_questions_path, notice: "問題を更新しました"
      else
        set_filter_options
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @question.discard
      redirect_to admin_questions_path, notice: "問題を削除しました"
    end

    # CSVインポートフォーム
    def import_form
      # フォーム表示のみ
    end

    # CSVインポート実行
    def import
      unless params[:file].present?
        redirect_to import_form_admin_questions_path, alert: "ファイルを選択してください"
        return
      end
      
      file = params[:file]
      result = Question.import_csv(file.path)
      
      if result[:errors].empty?
        redirect_to admin_questions_path, 
                    notice: "#{result[:success_count]}件の問題をインポートしました"
      else
        @import_result = result
        render :import_form, status: :unprocessable_entity
      end
    rescue StandardError => e
      redirect_to import_form_admin_questions_path, 
                  alert: "CSVインポートに失敗しました: #{e.message}"
    end

    # CSVエクスポート
    def export
      @questions = Question.kept.includes(:subject, :unit)
      
      # フィルター適用
      if params[:subject_id].present?
        @questions = @questions.where(subject_id: params[:subject_id])
      end
      
      if params[:unit_id].present?
        @questions = @questions.where(unit_id: params[:unit_id])
      end
      
      if params[:difficulty].present?
        @questions = @questions.where(difficulty: params[:difficulty])
      end
      
      csv_data = CSV.generate(headers: true) do |csv|
        # ヘッダー
        csv << [
          "科目ID", "単元ID", "問題タイプ", "難易度",
          "単語", "意味", "ヒント", "解答ノート"
        ]
        
        # データ
        @questions.find_each do |question|
          csv << [
            question.subject_id,
            question.unit_id,
            question.question_type,
            question.difficulty,
            question.word,
            question.meaning,
            question.hint,
            question.answer_note
          ]
        end
      end
      
      filename = "questions_#{Time.current.strftime('%Y%m%d')}.csv"
      send_data csv_data, filename: filename, type: "text/csv"
    end

    private

    def set_question
      @question = Question.kept.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_questions_path, alert: "問題が見つかりません"
    end

    def set_filter_options
      @subjects = Subject.ordered
      @units = Unit.ordered
      @difficulties = Question::DIFFICULTIES.keys
      @question_types = Question::QUESTION_TYPES.keys
    end

    def question_params
      params.require(:question).permit(
        :subject_id,
        :unit_id,
        :question_type,
        :difficulty,
        :word,
        :meaning,
        :hint,
        :answer_note
      )
    end
  end
end
