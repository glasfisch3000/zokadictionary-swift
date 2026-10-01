function handleSuccess() {
	document.getElementById("submit-form").hidden = true
	setTimeout(() => {
		window.location.href = returnAddress
	}, 1000)
}
