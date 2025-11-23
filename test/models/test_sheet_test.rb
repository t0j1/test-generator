require "test_helper"

class TestSheetTest < ActiveSupport::TestCase
  # ==================
  # バリデーションテスト
  # ==================

  test "valid test sheet" do
    test_sheet = TestSheet.new(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    assert test_sheet.valid?
  end

  test "requires subject" do
    test_sheet = TestSheet.new(
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    assert_not test_sheet.valid?
    assert_includes test_sheet.errors[:subject], "を入力してください"
  end

  test "requires unit" do
    test_sheet = TestSheet.new(
      subject: subjects(:english),
      difficulty: :easy,
      question_count: 3
    )
    assert_not test_sheet.valid?
    assert_includes test_sheet.errors[:unit], "を入力してください"
  end

  test "requires difficulty" do
    test_sheet = TestSheet.new(
      subject: subjects(:english),
      unit: units(:english_unit1),
      question_count: 3
    )
    assert_not test_sheet.valid?
    assert_includes test_sheet.errors[:difficulty], "を入力してください"
  end

  test "requires question_count" do
    test_sheet = TestSheet.new(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy
    )
    assert_not test_sheet.valid?
    assert_includes test_sheet.errors[:question_count], "を入力してください"
  end

  test "question_count must be at least 1" do
    test_sheet = TestSheet.new(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 0
    )
    assert_not test_sheet.valid?
    assert_includes test_sheet.errors[:question_count], "は1以上の値にしてください"
  end

  test "question_count must be at most 100" do
    test_sheet = TestSheet.new(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 101
    )
    assert_not test_sheet.valid?
    assert_includes test_sheet.errors[:question_count], "は100以下の値にしてください"
  end

  # ==================
  # 関連テスト
  # ==================

  test "belongs to subject" do
    test_sheet = TestSheet.new(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    assert_equal subjects(:english), test_sheet.subject
  end

  test "belongs to unit" do
    test_sheet = TestSheet.new(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    assert_equal units(:english_unit1), test_sheet.unit
  end

  test "has many test_questions" do
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    
    test_sheet.generate_questions!
    
    assert test_sheet.test_questions.count > 0
    assert_equal 3, test_sheet.test_questions.count
  end

  # ==================
  # generate_questions! メソッドテスト
  # ==================

  test "generate_questions! creates correct number of questions" do
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    
    test_sheet.generate_questions!
    
    assert_equal 3, test_sheet.test_questions.count
  end

  test "generate_questions! creates questions in order" do
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    
    test_sheet.generate_questions!
    
    orders = test_sheet.test_questions.pluck(:question_order)
    assert_equal [1, 2, 3], orders
  end

  test "generate_questions! raises error when insufficient questions" do
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 100  # 英単語は3問しかない
    )
    
    error = assert_raises(StandardError) do
      test_sheet.generate_questions!
    end
    
    assert_match(/問が不足しています/, error.message)
  end

  test "generate_questions! does not create duplicate questions" do
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    
    test_sheet.generate_questions!
    
    question_ids = test_sheet.test_questions.pluck(:question_id)
    assert_equal question_ids.uniq, question_ids, "Questions should not be duplicated"
  end

  test "generate_questions! filters by difficulty" do
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 2
    )
    
    test_sheet.generate_questions!
    
    # すべての問題が易しいレベルであることを確認
    test_sheet.test_questions.each do |tq|
      assert_equal "easy", tq.question.difficulty, "All questions should be easy"
    end
  end

  test "generate_questions! with normal difficulty" do
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :normal,
      question_count: 2
    )
    
    test_sheet.generate_questions!
    
    # すべての問題が普通レベルであることを確認
    test_sheet.test_questions.each do |tq|
      assert_equal "normal", tq.question.difficulty, "All questions should be normal"
    end
  end

  # ==================
  # Discard パターンテスト
  # ==================

  test "discarded test sheets are excluded by default" do
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: 1,  # easy
      question_count: 3
    )
    
    test_sheet.discard
    
    assert_not TestSheet.kept.exists?(test_sheet.id)
    assert TestSheet.discarded.exists?(test_sheet.id)
  end

  test "kept test sheets are included by default" do
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    
    assert TestSheet.all.include?(test_sheet)
    assert TestSheet.kept.include?(test_sheet)
  end
end
