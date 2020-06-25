function myFunction() {
    var input, filter, table, tr, td, i, pathname;
    input = document.getElementById("myInput");
    filter = input.value.toUpperCase();
    table = document.getElementById("list");
    tr = table.getElementsByTagName("tr");
    pathname = window.location.pathname;
    for (i = 0; i < tr.length; i++) {
        
        if (pathname === '/users_list' )
            td = tr[i].getElementsByTagName("td")[1];
        else if (pathname === '/topic_list'  || pathname === '/documents' || pathname === '/my_tags' || pathname === '/my_favorites' || pathname === '/my_upload_documents')
            td = tr[i].getElementsByTagName("td")[0];
        
        if (td) {
            txtValue = td.textContent || td.innerText ;
            console.log(txtValue);
            
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }
}