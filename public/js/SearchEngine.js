function myFunction() {
    var input, filter, table, tr, td, i, pathname;
    input = document.getElementById("myInput");
    filter = input.value.toUpperCase();
    table = document.getElementById("list");
    tr = table.getElementsByTagName("tr");
    pathname = window.location.pathname;
    for (i = 0; i < tr.length; i++) {
        
        if ( pathname === '/topic_list' || pathname === '/users_list' )
            td = tr[i].getElementsByTagName("td")[1];
        else if (pathname === '/documents')
            td = tr[i].getElementsByTagName("td")[0];
        
        if (td) {
            txtValue = td.textContent || td.innerText ;
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }
}