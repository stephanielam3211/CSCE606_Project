// for manage_data.html.erb
// This script handles the confirmation modal for form submissions
document.addEventListener("DOMContentLoaded", function () {
  let formToSubmit = null;

  const modal = document.getElementById("confirmModal");
  const input = document.getElementById("confirmInput");
  const cancel = document.getElementById("cancelButton");
  const proceed = document.getElementById("proceedButton");

  document.querySelectorAll(".confirm-before-submit").forEach(button => {
    button.addEventListener("click", function (e) {
      e.preventDefault();
      formToSubmit = button.closest("form");
      modal.classList.remove("hidden");
      input.value = "";
      input.focus();
    });
  });

  cancel.addEventListener("click", function () {
    modal.classList.add("hidden");
    formToSubmit = null;
  });

  proceed.addEventListener("click", function () {
    if (input.value === "CONFIRM" && formToSubmit) {
      modal.classList.add("hidden");
      formToSubmit.submit();
    } else {
      alert("❌ Incorrect confirmation. Action canceled.");
    }
  });
});
