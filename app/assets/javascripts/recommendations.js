// This file contains JavaScript code to handle the functionality of the new/edit recommendation form
    document.addEventListener("DOMContentLoaded", function () {
      if (window.location.href.includes("notice=")) {
        document.getElementById("recommendation_form").reset();
      }
    });

    $(document).ready(function () {
      if ($('#course-search_recs').length) {
        $('#course-search_recs').select2({
          placeholder: "Search for a course...",
          minimumInputLength: 1,
          ajax: {
            url: '/courses/search_recs',
            dataType: 'json',
            delay: 250,
            data: function (params) {
              return { term: params.term };
            },
            processResults: function (data) {
              return {
                results: data.map(course => ({
                  id: `CSCE ${course.course_number}`,
                  text: `${course.course_number} - ${course.section}: ${course.name}`
                }))
              };
            },
            cache: true
          }
        }).on("select2:select", function (e) {
          var selected = e.params.data;
          $("#course-section").val(selected.section);
        });
      }

      if ($('#ta-search').length) {
        $('#ta-search').select2({
          placeholder: "Search for a TA...",
          minimumInputLength: 1,
          ajax: {
            url: '/applicants/search',
            dataType: 'json',
            delay: 250,
            data: function (params) {
              return { term: params.term };
            },
            processResults: function (data) {
              return {
                results: data.map(ta => ({
                  id: ta.text,
                  text: `${ta.name} (${ta.email})`
                }))
              };
            },
            cache: true
          }
        });
      }
    });