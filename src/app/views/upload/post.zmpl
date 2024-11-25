<html>
<head>
<link rel="stylesheet" href="styles.css">
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>File Uploaded Successfully</h1>

<h2>Scrobbles Added</h2>

@partial partials/table(table_data: .scrobbles, table_headers: .upload_table, table_context: .context)

</body>
</html>