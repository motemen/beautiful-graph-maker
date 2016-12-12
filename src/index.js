const queryString = require('query-string');

const q = queryString.parse(location.search);

const state = {
  labels: {
    upper: q.y2 || '😊',
    lower: q.y1 || '🙁'
  },
  trend: q.a === '-1' ? 'falling' : 'rising'
};

const textLabelUpper = document.querySelector('#y-label-upper');
const textLabelLower = document.querySelector('#y-label-lower');

textLabelUpper.textContent = state.labels.upper;
textLabelLower.textContent = state.labels.lower;

textLabelUpper.addEventListener('click', function() { changeLabel('upper') });
textLabelLower.addEventListener('click', function() { changeLabel('lower') });

function updateURL() {
  history.replaceState(
    null, null, '?' + queryString.stringify({
      y2: state.labels.upper,
      y1: state.labels.lower,
      a: state.trend === 'falling' ? '-1' : '1',
    })
  );
}

function changeLabel(which) {
  state.labels[which] = prompt('Change ' + which + ' label');
  updateLabels();
  updateURL();
}

var lines = document.querySelectorAll('#line-up, #line-down');
for (var i = 0; i < lines.length; i++) {
  lines[i].addEventListener('click', function () {
    state.trend = state.trend === 'rising' ? 'falling' : 'rising';
    updateLines();
    updateURL();
  });
}

updateLines();

function updateLabels() {
  document.querySelector('#y-label-upper').textContent = state.labels.upper;
  document.querySelector('#y-label-lower').textContent = state.labels.lower;
}

function updateLines() {
  document.querySelector('#line-up').style.display   = state.trend === 'rising' ? '' : 'none';
  document.querySelector('#line-down').style.display = state.trend === 'rising' ? 'none' : '';
}

document.querySelector('#download').addEventListener('click', writeOut);

function writeOut() {
  // https://developer.mozilla.org/ja/docs/Web/HTML/Canvas/Drawing_DOM_objects_into_a_canvas
  // https://azu.github.io/t_wada_generator/t_wada.js
  var xml = new XMLSerializer().serializeToString(document.querySelector('svg'));
  var svg = new Blob([xml], { type: 'image/svg+xml; charset=utf-8' });

  var canvas = document.createElement('canvas');
  canvas.setAttribute('width',  '500');
  canvas.setAttribute('height', '500');

  var img = new Image;
  img.src = URL.createObjectURL(svg);
  img.onload = function () {
    var ctx = canvas.getContext('2d');
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, 500, 500);
    ctx.drawImage(img, 0, 0);
    URL.revokeObjectURL(img.src);

    canvas.toBlob(function (blob) {
      var a = document.createElement('a');
      a.download = 'graph.png';
      a.href = URL.createObjectURL(blob);
      a.click();
      URL.revokeObjectURL(a.href);
    }, 'image/png', 0.9);
  };
}
