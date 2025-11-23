require "test_helper"

class SubjectTest < ActiveSupport::TestCase
  # ==================
  # バリデーションテスト
  # ==================

  test "valid subject" do
    subject = Subject.new(
      name: "テスト科目",
      color_code: "#FF0000"
    )
    assert subject.valid?
  end

  test "requires name" do
    subject = Subject.new(
      color_code: "#FF0000"
    )
    assert_not subject.valid?
    assert_includes subject.errors[:name], "を入力してください"
  end

  test "name must be unique" do
    subject = Subject.new(
      name: subjects(:english).name,
      color_code: "#FF0000"
    )
    assert_not subject.valid?
    assert_includes subject.errors[:name], "はすでに存在します"
  end

  # ==================
  # 関連テスト
  # ==================

  test "has many units" do
    subject = subjects(:english)
    assert_respond_to subject, :units
  end

  test "has many test_sheets" do
    subject = subjects(:english)
    assert_respond_to subject, :test_sheets
  end

  # ==================
  # スコープテスト
  # ==================

  test "ordered scope orders by sort_order and id" do
    subjects = Subject.ordered
    assert_equal subjects, subjects.sort_by { |s| [s.sort_order, s.id] }
  end

  # ==================
  # コールバックテスト
  # ==================

  test "sets default color on create" do
    subject = Subject.create!(name: "英語")
    assert_equal "#EF4444", subject.color_code
  end

  test "sets gray color for unknown subject" do
    subject = Subject.create!(name: "不明科目")
    assert_equal "#6B7280", subject.color_code
  end

  test "does not override provided color" do
    subject = Subject.create!(name: "テスト科目B", color_code: "#123456")
    assert_equal "#123456", subject.color_code
  end

  # ==================
  # クラスメソッドテスト
  # ==================

  test "default_color_for returns correct color" do
    assert_equal "#EF4444", Subject.default_color_for("英語")
    assert_equal "#3B82F6", Subject.default_color_for("数学")
    assert_equal "#6B7280", Subject.default_color_for("未知の科目")
  end
end
