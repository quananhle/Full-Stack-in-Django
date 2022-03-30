## Model Details Template

To provides protection against ```Cross Site Request Forgeries```, I added the ```{% csrf_token %}``` template tag to the form, which adds a hidden input field containing a token that gets sent with each ```POST``` request.
