<html><head><title>OIDC Variables</title></head><body> 
<table> 
<?php 
ksort($_SERVER); 
foreach ($_SERVER as $key => $value) {
    if ((preg_match('/^OIDC/',$key)) ||
        (preg_match('/^REMOTE_USER/',$key))) {
        echo "<tr><td>$key</td><td>$value</td></tr>\n";
    } 
} 
?> 
</table> 
</body></html>
