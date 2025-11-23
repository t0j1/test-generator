require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  # ==================
  # バリデーションテスト
  # ==================

  test "valid question" do
    question = Question.new(
      unit: units(:english_unit1),
      question_type: :word,
      difficulty: :easy,
      question_text: "hello",
      answer_text: "こんにちは"
    )
    assert question.valid?
  end

  test "requires question_text" do
    question = Question.new(
      unit: units(:english_unit1),
      question_type: :word,
      difficulty: :easy,
      answer_text: "こんにちは"
    )
    assert_not question.valid?
    assert_includes question.errors[:question_text], "を入力してください"
  end

  test "requires answer_text" do
    question = Question.new(
      unit: units(:english_unit1),
      question_type: :word,
      difficulty: :easy,
      question_text: "hello"
    )
    assert_not question.valid?
    assert_includes question.errors[:answer_text], "を入力してください"
  end

  # ==================
  # 関連テスト
  # ==================

  test "belongs to unit" do
    question = questions(:english_easy_1)
    assert_equal units(:english_unit1), question.unit
  end

  test "has many test_questions" do
    question = questions(:english_easy_1)
    assert_respond_to question, :test_questions
  end

  test "delegates subject to unit" do
    question = questions(:english_easy_1)
    assert_equal subjects(:english), question.subject
  end

  test "delegates subject_id to unit" do
    question = questions(:english_easy_1)
    assert_equal subjects(:english).id, question.subject_id
  end

  # ==================
  # enumテスト
  # ==================

  test "question_type enum works" do
    question = questions(:english_easy_1)
    assert_equal "word", question.question_type
    
    question.question_type = :sentence
    assert_equal "sentence", question.question_type
  end

  test "difficulty enum works with prefix" do
    question = questions(:english_easy_1)
    assert question.difficulty_easy?
    
    question.difficulty = :normal
    assert question.difficulty_normal?
    
    question.difficulty = :hard
    assert question.difficulty_hard?
  end

  # ==================
  # Discard パターンテスト
  # ==================

  test "discarded questions are excluded by default" do
    question = questions(:english_easy_1)
    question_id = question.id
    question.discard
    
    # default_scopeの影響でQuestion.allには含まれない
    # データベースから再読み込みして確認
    assert_not Question.exists?(question_id), "Discarded question should not exist in default scope"
    # discardedスコープには含まれる
    assert Question.discarded.exists?(question_id), "Discarded question should exist in discarded scope"
  end

  test "kept questions are included by default" do
    question = questions(:english_easy_1)
    
    assert Question.all.include?(question)
    assert Question.kept.include?(question)
  end

  # ==================
  # CSVインポートテスト
  # ==================

  test "import_csv succeeds with valid data" do
    csv_content = <<~CSV
      単元ID,問題タイプ,難易度,問題文,解答,ヒント,解答ノート
      #{units(:english_unit1).id},word,easy,dog,犬,ペット,動物
      #{units(:english_unit1).id},word,normal,computer,コンピュータ,電子機器,IT
    CSV

    file = Tempfile.new(["questions", ".csv"])
    file.write(csv_content)
    file.rewind

    result = Question.import_csv(file.path)
    
    # デバッグ: エラーがあれば出力
    if result[:error_count] > 0
      puts "\n=== CSV Import Errors ==="
      puts "Errors: #{result[:errors].inspect}"
      puts "========================\n"
    end
    
    assert_equal 2, result[:success_count], "Expected 2 successful imports, but got #{result[:success_count]}. Errors: #{result[:errors].inspect}"
    assert_equal 0, result[:error_count]
    
    file.close
    file.unlink
  end

  test "import_csv handles errors gracefully" do
    csv_content = <<~CSV
      単元ID,問題タイプ,難易度,問題文,解答,ヒント,解答ノート
      #{units(:english_unit1).id},word,easy,,犬,ペット,動物
    CSV

    file = Tempfile.new(["questions", ".csv"])
    file.write(csv_content)
    file.rewind

    result = Question.import_csv(file.path)
    
    assert_equal 0, result[:success_count]
    assert_equal 1, result[:error_count]
    assert result[:errors].any?
    
    file.close
    file.unlink
  end
end
