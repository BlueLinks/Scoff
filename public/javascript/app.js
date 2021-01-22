const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const restaurantName = urlParams.get('name')
console.log(restaurantName);
document.getElementById("name").innerHTML = restaurantName