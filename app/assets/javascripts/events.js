// This polling could possibly be simpler using some of the newer Rails features such as ActionCable.
// I chose to write this from scratch because 1) it makes the app lighter and 2) I haven't written
// something like this in a while and it was good practice.

let queryParams = new URLSearchParams(location.search);

function triggerPoll() {
  if ($('.event-tile').length===0) {
    setTimeout(pollIndex, 5000);
  } else {
    $('#loading-message').empty();
    // flash message may be gone but rails can be unpredictable
    $('.flash-message').empty();
  }
};

function pollIndex() {
  if ($('.event-tile').length===0) {
    $.ajax({
      url: 'events/index',
      data: queryParams.toString(),
      type: 'GET',
      dataType: 'script',
      complete: triggerPoll,
    });
  }
};

$( function() {
  $('#loading-message').html('<p>loading...</p>');
  pollIndex();
});
