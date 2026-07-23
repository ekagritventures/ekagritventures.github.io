// Progressive enhancement for the footer subscribe form.
// Without JS: the form posts to Kit and opens its confirmation page in a new tab.
// With JS: the form posts into a hidden iframe (visitor stays on the page) and we
// show an inline success message that tells them to check spam/Promotions.
(function () {
  var forms = document.querySelectorAll("form.subscribe");
  if (!forms.length) return;

  // A hidden iframe to receive Kit's response so the page never navigates.
  var sink = document.createElement("iframe");
  sink.name = "kit-sink";
  sink.style.display = "none";
  sink.setAttribute("aria-hidden", "true");
  sink.tabIndex = -1;
  document.body.appendChild(sink);

  forms.forEach(function (form) {
    form.target = "kit-sink"; // override target="_blank" once JS is running
    var status = form.querySelector(".subscribe-status");

    form.addEventListener("submit", function () {
      // The browser only fires "submit" after the email field passes validation,
      // so at this point the native POST is proceeding into the hidden iframe.
      var row = form.querySelector(".subscribe-row");
      var note = form.querySelector(".subscribe-note");
      if (row) row.hidden = true;
      if (note) note.hidden = true;
      if (status) {
        status.hidden = false;
        status.innerHTML =
          "Almost there — check your inbox to confirm. If it’s not there in a minute, look in <strong>spam</strong> or the <strong>Promotions</strong> tab.";
      }
    });
  });
})();
