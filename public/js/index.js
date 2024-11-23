window.onload = function() {
  // 二重送信防止
  let buttons = document.getElementsByClassName('submit');
  Array.from(buttons).forEach(button => {
    button.addEventListener('click', (event) => {
      event.target.classList.add('disabled');
    });
  });

  // 未入力なら非活性
  let single_number_input = document.getElementById('requestNumber');
  let single_submit_button = document.getElementById('single_submit');
  single_number_input.addEventListener('change', (event) => {
    let input = event.target;
    if (Number(input.value) === 0) {
      single_submit_button.classList.add('disabled');
    } else {
      single_submit_button.classList.remove('disabled');
    }
  });

  let multiple_number_csv_input = document.getElementById('requestNumberCsv');
  let csv_submit_button = document.getElementById('csv_submit');
  multiple_number_csv_input.addEventListener('change', (event) => {
    let input = event.target;
    if (input.value === '') {
      csv_submit_button.classList.add('disabled');
    } else {
      csv_submit_button.classList.remove('disabled');
    }
  });

  // ページング関連
  let select = document.getElementById("view_count");
  select.addEventListener('change', (event) => {
    let target = event.target;
    let url = window.location.origin + window.location.pathname + '?view_count=' + target.value + '&page=1';
    window.location.href = url;
  });
};