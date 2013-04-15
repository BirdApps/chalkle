$("#teaching_teacher_cost").keyup (e) ->
  if e.target.value > 0
    $("#teaching_price").val "tata"
  else if e.target.value is ""
    $("#teaching_price").val 0
  else
    $("#teaching_price").val "Select a channel then re-enter your amount"
    