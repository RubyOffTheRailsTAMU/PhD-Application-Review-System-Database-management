$(document).ready(function() {
    console.log("Document ready!");
    var clearButton = $("#clear-database-button");
    var modalContainer = $("#modal-container");
    var yesButton = $("#confirm-yes");
    var noButton = $("#confirm-no");
  
    clearButton.on("click", function() {
      console.log("Clear button clicked!");
      modalContainer.show(); // Display the modal container in the center of the screen
    });
 
    yesButton.on("click", function() {
      console.log("Yes button clicked!");
      window.location.href = '/clear_database'; // Navigate to the specified URL after confirmation
    });
 
    noButton.on("click", function() {
      console.log("No button clicked!");
      modalContainer.hide(); // Hide the modal container
    });
 });