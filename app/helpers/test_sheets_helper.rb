module TestSheetsHelper
  # 難易度の選択肢（ミックス含む）
  def difficulty_options_for_select_with_mix
    options = [["ミックス(全難易度)", nil]]
    options += TestSheet::DIFFICULTY_LABELS.map { |key, label| [label, key] }
    options
  end

  # 問題数の選択肢
  def question_count_options
    counts = [5, 10, 15, 20, 25, 30, 40, 50]
    counts.map { |c| [c, c] }
  end

  # 学年の選択肢
  def grade_options_for_select
    Unit::VALID_GRADES.map do |grade|
      ["高#{grade}", grade]
    end
  end

  # 難易度ラベルの表示（nilの場合はミックス）
  def difficulty_label_for_display(test_sheet)
    if test_sheet.difficulty.nil?
      TestSheet::MIX_LABEL
    else
      test_sheet.difficulty_label
    end
  end

  # 科目の色コードを取得
  def subject_color(subject)
    subject.color_code || Subject::DEFAULT_COLORS[subject.name] || "#6B7280"
  end

  # 問題番号のフォーマット（1. 2. 3. ...）
  def question_number_label(order)
    "#{order}."
  end

  # 問題タイプのアイコン
  def question_type_icon(question)
    case question.question_type
    when "word"
      "📝"
    when "sentence"
      "📄"
    when "calculation"
      "🔢"
    else
      "❓"
    end
  end

  # 難易度のバッジカラー
  def difficulty_badge_color(difficulty)
    case difficulty
    when "easy"
      "bg-green-100 text-green-800"
    when "normal"
      "bg-blue-100 text-blue-800"
    when "hard"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  # 印刷ステータスのバッジ
  def print_status_badge(test_sheet)
    if test_sheet.printed?
      content_tag(:span, "印刷済み",
                  class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800")
    else
      content_tag(:span, "未印刷",
                  class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800")
    end
  end

  # テスト生成日時のフォーマット
  def format_test_created_at(test_sheet)
    test_sheet.created_at.strftime("%Y年%m月%d日 %H:%M")
  end

  # 印刷日時のフォーマット
  def format_printed_at(test_sheet)
    return "未印刷" unless test_sheet.printed?

    test_sheet.printed_at.strftime("%Y年%m月%d日 %H:%M")
  end
end
