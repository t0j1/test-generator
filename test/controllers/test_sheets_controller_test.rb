require "test_helper"

class TestSheetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # 科目作成
    @subject = Subject.create!(
      name: "英語",
      display_order: 1
    )
    
    # 単元作成
    @unit = Unit.create!(
      subject: @subject,
      name: "現在完了形",
      grade: 1,
      display_order: 1
    )
    
    # 問題作成
    10.times do |i|
      Question.create!(
        unit: @unit,
        difficulty: %w[easy normal hard].sample,
        word: "test_word_#{i}",
        meaning: "テスト単語#{i}",
        hint: "ヒント#{i}"
      )
    end
  end

  test "should get new" do
    get new_test_sheet_url
    assert_response :success
    assert_select "h1", "単語テスト作成"
    assert_select "[data-controller='test-form']"
  end

  test "should have hidden class on unit section" do
    get new_test_sheet_url
    assert_response :success
    
    # 単元選択セクションに hidden クラスが付いていることを確認
    assert_select "[data-test-form-target='unitSection'].hidden"
    
    # インラインスタイル style="display: none;" が無いことを確認
    response_body = @response.body
    refute_match(/data-test-form-target="unitSection"[^>]*style="display:\s*none/, response_body,
                 "unitSection should not have inline style='display: none;'")
  end

  test "should have hidden class on settings section" do
    get new_test_sheet_url
    assert_response :success
    
    # 設定セクションに hidden クラスが付いていることを確認
    assert_select "[data-test-form-target='settingsSection'].hidden"
    
    # インラインスタイル style="display: none;" が無いことを確認
    response_body = @response.body
    refute_match(/data-test-form-target="settingsSection"[^>]*style="display:\s*none/, response_body,
                 "settingsSection should not have inline style='display: none;'")
  end

  test "should have hidden class on submit section" do
    get new_test_sheet_url
    assert_response :success
    
    # 送信ボタンセクションに hidden クラスが付いていることを確認
    assert_select "[data-test-form-target='submitSection'].hidden"
    
    # インラインスタイル style="display: none;" が無いことを確認
    response_body = @response.body
    refute_match(/data-test-form-target="submitSection"[^>]*style="display:\s*none/, response_body,
                 "submitSection should not have inline style='display: none;'")
  end

  test "units_by_subject should return units for valid subject" do
    get units_by_subject_test_sheets_url, params: { subject_id: @subject.id }
    assert_response :success
    
    json = JSON.parse(@response.body)
    assert_equal @subject.id, json["subject_id"]
    assert_equal "英語", json["subject_name"]
    assert_equal 1, json["units"].length
    assert_equal "現在完了形", json["units"].first["name"]
  end

  test "units_by_subject should return 404 for invalid subject" do
    get units_by_subject_test_sheets_url, params: { subject_id: 99999 }
    assert_response :not_found
    
    json = JSON.parse(@response.body)
    assert_equal "科目が見つかりません", json["error"]
  end

  test "available_questions should return question count" do
    get available_questions_test_sheets_url, params: { 
      unit_id: @unit.id,
      difficulty: ""
    }
    assert_response :success
    
    json = JSON.parse(@response.body)
    assert_equal @unit.id, json["unit_id"]
    assert_equal 10, json["available_count"]
  end

  test "available_questions should filter by difficulty" do
    # easy問題を3つ作成
    3.times do |i|
      Question.create!(
        unit: @unit,
        difficulty: "easy",
        word: "easy_word_#{i}",
        meaning: "簡単な単語#{i}",
        hint: "ヒント#{i}"
      )
    end
    
    get available_questions_test_sheets_url, params: { 
      unit_id: @unit.id,
      difficulty: "easy"
    }
    assert_response :success
    
    json = JSON.parse(@response.body)
    assert_operator json["available_count"], :>=, 3
  end

  test "should create test_sheet with valid params" do
    assert_difference("TestSheet.count") do
      post test_sheets_url, params: { 
        test_sheet: {
          subject_id: @subject.id,
          unit_id: @unit.id,
          difficulty: "",
          question_count: 5,
          include_hint: true,
          include_answer: true
        }
      }
    end
    
    assert_redirected_to test_sheet_path(TestSheet.last)
  end
end
