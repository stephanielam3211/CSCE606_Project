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

  const importForm = document.getElementById("importForm");
    const importSubmitButton = document.getElementById("importSubmitButton");
    const importModal = document.getElementById("importConfirmModal");
    const cancelImportButton = document.getElementById("cancelImportButton");
    const proceedImportButton = document.getElementById("proceedImportButton");

    let formConfirmed = false;

    importForm.addEventListener("submit", function (e) {
      if (!formConfirmed) {
        e.preventDefault(); 
        importModal.classList.remove("hidden");
      }
    });

    cancelImportButton.addEventListener("click", function () {
      importModal.classList.add("hidden");
    });

    proceedImportButton.addEventListener("click", function () {
      formConfirmed = true;
      importModal.classList.add("hidden");
      importForm.submit(); 
    });
});
