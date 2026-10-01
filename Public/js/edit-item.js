function handleSuccess() {
	document.getElementById("input-form").hidden = true
	setTimeout(() => {
		window.location.href = returnAddress
	}, 1000)
}
