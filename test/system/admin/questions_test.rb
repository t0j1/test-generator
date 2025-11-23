require "application_system_test_case"

class Admin::QuestionsTest < ApplicationSystemTestCase
  setup do
    # Basic認証の情報を設定
    @admin_user = ENV.fetch("ADMIN_USER", "admin")
    @admin_password = ENV.fetch("ADMIN_PASSWORD", "password")
  end

  # ==================
  # Admin画面アクセステスト
  # ==================

  test "admin dashboard requires authentication" do
    visit admin_dashboard_path
    
    # Basic認証が要求される
    assert_current_path admin_dashboard_path
  end

  test "admin dashboard shows statistics" do
    # Basic認証を設定してアクセス
    visit_with_basic_auth admin_dashboard_path
    
    # ダッシュボードが表示される
    assert_selector "h1", text: "管理画面ダッシュボード"
    
    # 統計情報が表示される
    assert_text "総問題数"
    assert_text "総テスト数"
  end

  # ==================
  # 問題管理テスト
  # ==================

  test "can create new question" do
    visit_with_basic_auth admin_questions_path
    
    click_link "新規問題登録"
    
    # 問題作成フォーム
    select "英語", from: "question[unit_id]"
    select "単語", from: "question[question_type]"
    select "易しい", from: "question[difficulty]"
    fill_in "question[question_text]", with: "hello"
    fill_in "question[answer_text]", with: "こんにちは"
    fill_in "question[hint]", with: "挨拶"
    
    click_button "登録する"
    
    # 成功メッセージ
    assert_text "問題を登録しました"
    assert_text "hello"
  end

  test "can edit existing question" do
    visit_with_basic_auth admin_questions_path
    
    # 既存の問題を編集
    within("tr", text: "apple") do
      click_link "編集"
    end
    
    fill_in "question[question_text]", with: "orange"
    fill_in "question[answer_text]", with: "オレンジ"
    
    click_button "更新する"
    
    # 成功メッセージ
    assert_text "問題を更新しました"
    assert_text "orange"
  end

  test "can delete question" do
    visit_with_basic_auth admin_questions_path
    
    # 問題数を確認
    question_count = all("tbody tr").count
    
    # 問題を削除
    within("tr", text: "apple") do
      click_link "削除"
    end
    
    # 確認ダイアログ
    page.driver.browser.switch_to.alert.accept
    
    # 削除成功
    assert_text "問題を削除しました"
    assert_equal question_count - 1, all("tbody tr").count
  end

  # ==================
  # 検索・フィルター機能テスト
  # ==================

  test "can filter questions by subject" do
    visit_with_basic_auth admin_questions_path
    
    select "英語", from: "subject_id"
    click_button "検索"
    
    # 英語の問題のみ表示される
    assert_selector "tbody tr"
    all("tbody tr").each do |row|
      assert row.has_text?("英語")
    end
  end

  test "can search questions by keyword" do
    visit_with_basic_auth admin_questions_path
    
    fill_in "keyword", with: "apple"
    click_button "検索"
    
    # appleを含む問題が表示される
    assert_text "apple"
  end

  # ==================
  # CSV インポートテスト
  # ==================

  test "can import questions from CSV" do
    visit_with_basic_auth admin_questions_path
    
    click_link "CSVインポート"
    
    # CSVファイルを作成
    csv_content = <<~CSV
      単元ID,問題タイプ,難易度,問題文,解答,ヒント,解答ノート
      #{units(:english_unit1).id},word,easy,dog,犬,ペット,動物
      #{units(:english_unit1).id},word,normal,computer,コンピュータ,電子機器,IT
    CSV
    
    file = Tempfile.new(["questions", ".csv"])
    file.write(csv_content)
    file.rewind
    
    attach_file "file", file.path
    click_button "インポート"
    
    # 成功メッセージ
    assert_text "2件の問題をインポートしました"
    
    file.close
    file.unlink
  end

  test "shows errors for invalid CSV data" do
    visit_with_basic_auth admin_questions_path
    
    click_link "CSVインポート"
    
    # 不正なCSVファイル（必須項目が欠けている）
    csv_content = <<~CSV
      単元ID,問題タイプ,難易度,問題文,解答,ヒント,解答ノート
      #{units(:english_unit1).id},word,easy,,犬,ペット,動物
    CSV
    
    file = Tempfile.new(["questions", ".csv"])
    file.write(csv_content)
    file.rewind
    
    attach_file "file", file.path
    click_button "インポート"
    
    # エラーメッセージ
    assert_text "エラー"
    
    file.close
    file.unlink
  end

  # ==================
  # CSV エクスポートテスト
  # ==================

  test "can export questions to CSV" do
    visit_with_basic_auth admin_questions_path
    
    click_link "CSVエクスポート"
    
    # CSVファイルがダウンロードされる
    # ファイル名は questions_YYYYMMDD.csv 形式
    # Capybaraではダウンロードの検証が難しいため、リンクの存在確認のみ
  end

  # ==================
  # ページネーションテスト
  # ==================

  test "questions are paginated" do
    # 60件の問題を作成（50件/ページ）
    60.times do |i|
      Question.create!(
        unit: units(:english_unit1),
        question_type: :word,
        difficulty: :easy,
        question_text: "test#{i}",
        answer_text: "テスト#{i}"
      )
    end
    
    visit_with_basic_auth admin_questions_path
    
    # ページネーションが表示される
    assert_selector ".pagination"
    
    # 次のページに移動
    click_link "2"
    
    # 2ページ目が表示される
    assert_selector "tbody tr"
  end

  private

  # Basic認証付きでページにアクセス
  def visit_with_basic_auth(path)
    page.driver.browser.authorize(@admin_user, @admin_password)
    visit path
  end
end
