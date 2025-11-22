module TestSheetsHelper
  # 難易度の選択肢を取得（フォーム用）
  def difficulty_options_for_select
    TestSheet.difficulty_options_for_select
  end
  
  # 問題タイプの選択肢を取得（フォーム用）
  def question_type_options_for_select
    Question.question_type_options_for_select
  end
  
  # 難易度のラベルを取得（表示用）
  def difficulty_label(difficulty)
    return TestSheet::MIX_LABEL if difficulty.nil?
    TestSheet::DIFFICULTY_LABELS[difficulty.to_s] || difficulty.to_s
  end
  
  # 問題タイプのラベルを取得（表示用）
  def question_type_label(question_type)
    Question::QUESTION_TYPE_LABELS[question_type.to_s] || question_type.to_s
  end
  
  # 学年の選択肢を取得（フォーム用）
  def grade_options_for_select
    Unit.grade_options_for_select
  end
end
