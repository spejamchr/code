n = limit
limit = 3
while n >= 1
  m = limit
  while m >= 1
    p = limit
    while p >= 1
      question = Question.new(user_id: User.all[(n*m*p) % User.count].id, title: "Question #{n}:#{m}:#{p}", body: "This is the body of Question #{n}:#{m}:#{p} by #{User.all[n % User.count].name}", views: (m*10), me_toos: p, created_at: Time.new-(n*10*60*60*24), scope: 'TLUSA')
      question.save
      p -= 1
    end
    m -= 1
  end
  n -= 1
end
