// This file contains JavaScript code for handling the edit assignment page.
  document.addEventListener("DOMContentLoaded", function () {
    if (window.location.href.includes("notice=")) {
      document.getElementById("recommendation_form").reset();
    }
  });

    const initializeSelect2 = (selector, placeholder, ajaxUrl, onSelectCallback) => {
    if ($(selector).length) {
      $(selector).select2({
        placeholder: placeholder,
        minimumInputLength: 1,
        ajax: {
          url: ajaxUrl,
          dataType: 'json',
          delay: 250,
          data: function (params) {
            return { term: params.term };
          },
          processResults: function (data) {
            return {
              results: data.map(item => ({
                id: item.id,
                text: item.name,
                email: item.email,
                uin: item.uin
              }))
            };
          },
          cache: true
        }
      }).on("select2:select", function (e) {
        const selectedData = e.params.data;
        onSelectCallback(selectedData);
      });
    }
  };

  const populateFields = (data) => {
    $('#ta-search').val(data.id).trigger('change.select2'); 
    $('#stu_email').val(data.email).trigger('change.select2');
    $('#uin').val(data.uin).trigger('change.select2');

    let newOptionName = new Option(data.text, data.name, true, true);
    let newOptionEmail = new Option(data.email, data.email, true, true);
    let newOptionUIN = new Option(data.uin, data.uin, true, true);

    $('#ta-search').append(newOptionName).trigger('change');
    $('#stu_email').append(newOptionEmail).trigger('change');
    $('#uin').append(newOptionUIN).trigger('change');
  };
  $(document).ready(function () {
    initializeSelect2('#ta-search', "Search for a TA...", '/unassigned_applicants/search', function(data) {
      populateFields(data);
    });
    initializeSelect2('#stu_email', "Search for an Email...", '/unassigned_applicants/search_email', function(data) {
      populateFields(data);
    });
    initializeSelect2('#uin', "Search for a UIN...", '/unassigned_applicants/search_uin', function(data) {
      populateFields(data);
    });
  });
