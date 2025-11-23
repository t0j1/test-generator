require "test_helper"

class UnitTest < ActiveSupport::TestCase
  # ==================
  # バリデーションテスト
  # ==================

  test "valid unit" do
    unit = Unit.new(
      subject: subjects(:english),
      name: "テスト単元",
      grade: 1,
      sort_order: 1
    )
    assert unit.valid?
  end

  test "requires name" do
    unit = Unit.new(
      subject: subjects(:english),
      grade: 1
    )
    assert_not unit.valid?
    assert_includes unit.errors[:name], "を入力してください"
  end

  test "grade must be in valid range" do
    unit = Unit.new(
      subject: subjects(:english),
      name: "テスト単元",
      grade: 0
    )
    assert_not unit.valid?

    unit.grade = 4
    assert_not unit.valid?

    unit.grade = 1
    assert unit.valid?
  end

  # ==================
  # 関連テスト
  # ==================

  test "belongs to subject" do
    unit = units(:english_unit1)
    assert_equal subjects(:english), unit.subject
  end

  test "has many questions" do
    unit = units(:english_unit1)
    assert_respond_to unit, :questions
  end

  test "has many test_sheets" do
    unit = units(:english_unit1)
    assert_respond_to unit, :test_sheets
  end

  # ==================
  # スコープテスト
  # ==================

  test "for_grade scope filters by grade" do
    units = Unit.for_grade(1)
    assert units.all? { |u| u.grade == 1 }
  end

  test "ordered scope orders by sort_order and id" do
    units = Unit.ordered
    # sort_orderが同じ場合はidでソート
    assert_equal units, units.sort_by { |u| [u.sort_order, u.id] }
  end

  # ==================
  # インスタンスメソッドテスト
  # ==================

  test "question_count returns total questions" do
    unit = units(:english_unit1)
    # fixtureから6問（easy: 3, normal: 2, hard: 1）
    assert_equal 6, unit.question_count
  end

  test "question_count with difficulty filters questions" do
    unit = units(:english_unit1)
    # easy問題は3問
    assert_equal 3, unit.question_count(difficulty: :easy)
  end

  test "question_counts_by_difficulty returns hash" do
    unit = units(:english_unit1)
    counts = unit.question_counts_by_difficulty
    
    assert counts.key?(:total)
    assert counts.key?(:easy)
    assert counts.key?(:normal)
    assert counts.key?(:hard)
    
    assert_equal 6, counts[:total]
    assert_equal 3, counts[:easy]
    assert_equal 2, counts[:normal]
    assert_equal 1, counts[:hard]
  end

  test "grade_label returns Japanese label" do
    unit = units(:english_unit1)
    assert_equal "高1", unit.grade_label
  end

  # ==================
  # クラスメソッドテスト
  # ==================

  test "grade_options_for_select returns array for select" do
    options = Unit.grade_options_for_select
    assert_equal [["高1", 1], ["高2", 2], ["高3", 3]], options
  end
end
