module Admin
  class DashboardController < ApplicationController
    layout "admin"
    def index
      # 統計情報
      @total_questions = Question.kept.count
      @total_test_sheets = TestSheet.kept.count
      
      # 科目別問題数
      @questions_by_subject = Subject.ordered.map do |subject|
        {
          subject: subject,
          count: subject.questions.kept.count
        }
      end
      
      # 難易度別問題数
      @questions_by_difficulty = {
        easy: Question.kept.difficulty_easy.count,
        normal: Question.kept.difficulty_normal.count,
        hard: Question.kept.difficulty_hard.count
      }
      
      # 最近作成されたテスト
      @recent_test_sheets = TestSheet.kept
                                     .includes(:subject, :unit)
                                     .order(created_at: :desc)
                                     .limit(10)
      
      # 最近追加された問題
      @recent_questions = Question.kept
                                  .includes(:unit, :subject)
                                  .order(created_at: :desc)
                                  .limit(10)
    end

    def show
      redirect_to admin_root_path
    end
  end
end
