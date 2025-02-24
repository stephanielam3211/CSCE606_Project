import { Turbo } from "turbo-rails"

// If you're using other Rails JS features like UJS or ActiveStorage, you should import them as needed.
// Rails UJS might still be needed for handling form submissions, etc.
import Rails from "@rails/ujs"
Rails.start()
function confirmClear() {
    return window.confirm("Are you sure you want to delete all courses?");
  }
// Import all other files in the app/javascript directory
import "channels"