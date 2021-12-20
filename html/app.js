const { useQuasar } = Quasar
const { ref } = Vue

const app = Vue.createApp({
  setup () {
    const $q = useQuasar()

    const content = ref(null)
    const radius = ref(null)
    const color = ref(null)
    const size = ref(null)
    const font = ref('1')

    return {
      content,
      radius,
      color,
      size,
      font,
      onSubmit () {
        if (color.value === null | radius.value === null | content.value === null | size.value === null) {
          $q.notify({
            color: 'red-5',
            textColor: 'white',
            icon: 'warning',
            message: 'You need to complete all inputs'
          })
        }
        else {
          sendNUICB({
            content: content.value,
            radius: radius.value,
            size: size.value,
            font: font.value,
            red: colorConvert(color.value).r,
            green: colorConvert(color.value).g,
            blue: colorConvert(color.value).b,
        }); 
        resetValues(content, color, radius, size)
        }
      },
    }
  }
})

app.use(Quasar, { config: {} })
app.mount('#menu')

document.onkeyup = function (data) {
  if (data.key == 'Escape') {
    closeMenu()
  }
};

function closeMenu() {
  $("#openmenu").fadeOut(550);
  $.post('https://nui_drawtext/closeMenu');
}

function resetValues(content, radius, color, size) {
  content.value = null
  radius.value = null
  color.value = null
  size.value = null
} 

function colorConvert(hex){
  var shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
  hex = hex.replace(shorthandRegex, function(m, r, g, b) {
    return r + r + g + g + b + b;
  });

  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}



$(document).ready(function () {
  window.addEventListener("message", function (event) {
    switch (event.data.action) {
    case "open":
      Open(event.data);
      break;
    }
  });
});

Open = function (data) {
  $("#openmenu").fadeIn(150);
}
$('.closeMenu').click(() => {
  closeMenu()
});
$('.Close').click(() => {
  closeMenu()
});

function sendNUICB(data = {}, cb = () => {}) {
fetch(`https://nui_drawtext/createDrawText`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json; charset=UTF-8', },
  body: JSON.stringify(data)
}).then(resp => resp.json()).then(resp => cb(resp));
}