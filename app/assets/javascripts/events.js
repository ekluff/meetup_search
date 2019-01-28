let queryParams = new URLSearchParams(location.search);

function triggerPoll() {
  if ($('.event-tile').length===0) {
    setTimeout(pollIndex, 5000);
  } else {
    $('#loading-message').empty();
  }
};

function pollIndex() {
  // not sure why this doesn't happen until the second time through this function
  $('#loading-message').html('<p>loading...</p>');

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

$( pollIndex() );
