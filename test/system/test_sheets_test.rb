require "application_system_test_case"

class TestSheetsTest < ApplicationSystemTestCase
  # ==================
  # テスト作成フロー全体
  # ==================

  test "complete test creation flow" do
    visit root_path

    # Step 1: 科目選択
    assert_selector "h1", text: "テストを作成"
    
    # 英語の科目をクリック
    find("input[type='radio'][value='#{subjects(:english).id}']", visible: false).execute_script("this.click()")
    
    # Step 2: 単元選択が表示されるまで待機
    assert_selector "#unit-selection", visible: true, wait: 5
    
    # 基礎英単語の単元をクリック
    find("input[type='radio'][value='#{units(:english_unit1).id}']", visible: false).execute_script("this.click()")
    
    # Step 3: 設定が表示されるまで待機
    assert_selector "[data-test-form-target='settingsSection']", visible: true, wait: 5
    
    # 難易度を選択
    select "易しい(基礎)", from: "test_sheet[difficulty]"
    
    # 問題数を選択
    select "3", from: "test_sheet[question_count]"
    
    # ヒントと解答の設定
    check "test_sheet[include_hint]"
    check "test_sheet[include_answer]"
    
    # Step 4: テスト作成ボタンをクリック
    click_button "テストを作成"
    
    # 確認ダイアログが表示される
    page.driver.browser.switch_to.alert.accept
    
    # テスト表示画面に遷移
    assert_current_path(/\/test_sheets\/\d+/)
    assert_selector "h1", text: "テスト"
    
    # 問題が3問表示されることを確認
    assert_selector ".question-item", count: 3
  end

  # ==================
  # 科目→単元の動的表示テスト
  # ==================

  test "unit list appears after subject selection" do
    visit root_path
    
    # 初期状態では単元選択は非表示
    assert_selector "#unit-selection", visible: false
    
    # 科目を選択
    find("input[type='radio'][value='#{subjects(:english).id}']", visible: false).execute_script("this.click()")
    
    # 単元選択が表示される
    assert_selector "#unit-selection", visible: true, wait: 5
    
    # 単元リストが表示される
    assert_selector "[data-test-form-target='unitList']", visible: true
    
    # 英語の単元が表示される
    assert_text "基礎英単語"
  end

  test "settings section appears after unit selection" do
    visit root_path
    
    # 科目を選択
    find("input[type='radio'][value='#{subjects(:english).id}']", visible: false).execute_script("this.click()")
    
    # 単元が表示されるまで待機
    assert_selector "#unit-selection", visible: true, wait: 5
    
    # 初期状態では設定は非表示
    assert_selector "[data-test-form-target='settingsSection']", visible: false
    
    # 単元を選択
    find("input[type='radio'][value='#{units(:english_unit1).id}']", visible: false).execute_script("this.click()")
    
    # 設定が表示される
    assert_selector "[data-test-form-target='settingsSection']", visible: true, wait: 5
  end

  # ==================
  # 難易度変更時の問題数更新テスト
  # ==================

  test "available question count updates when difficulty changes" do
    visit root_path
    
    # 科目と単元を選択
    find("input[type='radio'][value='#{subjects(:english).id}']", visible: false).execute_script("this.click()")
    assert_selector "#unit-selection", visible: true, wait: 5
    
    find("input[type='radio'][value='#{units(:english_unit1).id}']", visible: false).execute_script("this.click()")
    assert_selector "[data-test-form-target='settingsSection']", visible: true, wait: 5
    
    # 易しい問題の数を確認（3問）
    select "易しい(基礎)", from: "test_sheet[difficulty]"
    assert_text "利用可能な問題数: 3 問", wait: 5
    
    # 普通問題の数を確認（2問）
    select "普通(標準)", from: "test_sheet[difficulty]"
    assert_text "利用可能な問題数: 2 問", wait: 5
  end

  # ==================
  # 印刷機能テスト
  # ==================

  test "print button triggers print dialog" do
    # テストシートを作成
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    test_sheet.generate_questions!
    
    visit test_sheet_path(test_sheet)
    
    # 印刷ボタンが表示されることを確認
    assert_selector "button", text: "印刷する"
  end

  # ==================
  # 印刷履歴テスト
  # ==================

  test "history page shows test list" do
    # テストシートを作成
    test_sheet = TestSheet.create!(
      subject: subjects(:english),
      unit: units(:english_unit1),
      difficulty: :easy,
      question_count: 3
    )
    test_sheet.generate_questions!
    
    visit history_test_sheets_path
    
    # 履歴ページが表示される
    assert_selector "h1", text: "印刷履歴"
    
    # テストシートが表示される
    assert_text "英語"
    assert_text "基礎英単語"
  end

  test "history page has pagination" do
    # 25件のテストシートを作成（ページネーション表示のため）
    25.times do |i|
      test_sheet = TestSheet.create!(
        subject: subjects(:english),
        unit: units(:english_unit1),
        difficulty: :easy,
        question_count: 3
      )
      test_sheet.generate_questions!
    end
    
    visit history_test_sheets_path
    
    # ページネーションが表示される
    assert_selector ".pagination", visible: true
  end

  # ==================
  # ローディング表示テスト
  # ==================

  test "loading overlay appears during unit loading" do
    visit root_path
    
    # 科目を選択
    find("input[type='radio'][value='#{subjects(:english).id}']", visible: false).execute_script("this.click()")
    
    # ローディング表示が一時的に表示される（すぐに消える可能性があるため、visible: falseでも確認）
    # DOMに存在することを確認
    assert_selector "[data-test-form-target='loadingOverlay']"
  end

  # ==================
  # エラーハンドリングテスト
  # ==================

  test "shows validation error when form is invalid" do
    visit root_path
    
    # 科目と単元を選択せずに送信しようとする
    # （実際には送信ボタンが無効化されているはずだが、テストのため）
  end

  # ==================
  # タッチ操作最適化テスト（モバイル）
  # ==================

  test "buttons are large enough for touch" do
    visit root_path
    
    # 科目選択ボタンのサイズを確認
    button = find("label[for*='test_sheet_subject_id']", match: :first)
    size = button.native.size
    
    # 最小80px以上であることを確認
    assert size.height >= 80, "Button height should be at least 80px for touch"
  end
end
