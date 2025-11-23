# データベースの状態を確認するスクリプト

puts "=" * 60
puts "データベース状態チェック"
puts "=" * 60

puts "\n【科目 (Subjects)】"
puts "件数: #{Subject.count}"
if Subject.any?
  Subject.all.each do |s|
    puts "  ID: #{s.id}, 名前: #{s.name}, 単元数: #{s.units.count}"
  end
else
  puts "  ⚠️  科目データが存在しません"
end

puts "\n【単元 (Units)】"
puts "件数: #{Unit.count}"
if Unit.any?
  Unit.includes(:subject).all.each do |u|
    puts "  ID: #{u.id}, 名前: #{u.name}, 科目: #{u.subject.name}, 学年: #{u.grade}, 問題数: #{u.questions.count}"
  end
else
  puts "  ⚠️  単元データが存在しません"
end

puts "\n【問題 (Questions)】"
puts "件数: #{Question.count}"
if Question.any?
  Question.group(:unit_id).count.each do |unit_id, count|
    unit = Unit.find(unit_id)
    puts "  単元: #{unit.name} - 問題数: #{count}"
  end
else
  puts "  ⚠️  問題データが存在しません"
end

puts "\n" + "=" * 60
puts "チェック完了"
puts "=" * 60
