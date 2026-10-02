function handleSuccess() {
	document.getElementById("input-panel").hidden = true
	setTimeout(() => {
		window.location.href = returnAddress
	}, 1000)
}
