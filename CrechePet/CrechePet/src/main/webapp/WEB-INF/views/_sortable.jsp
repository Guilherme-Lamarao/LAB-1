<%-- Include este arquivo nos JSPs que precisam de tabelas ordenÃ¡veis --%>
<style>
.sortable-th {
    cursor: pointer;
    user-select: none;
    white-space: nowrap;
}
.sortable-th:hover { background: #e2e8f0; }
.sortable-th::after { content: '<>'; color: #94a3b8; font-size: .75rem; }
.sortable-th.asc::after  { content: '<>'; color: #3b82f6; }
.sortable-th.desc::after { content: '<>†“'; color: #3b82f6; }
</style>
<script>
function sortTable(tableId, colIndex, type) {
    const table  = document.getElementById(tableId);
    const tbody  = table.querySelector('tbody');
    const ths    = table.querySelectorAll('thead th.sortable-th');
    const th     = ths[colIndex];
    const asc    = th.dataset.dir !== 'asc';

    ths.forEach(h => { h.dataset.dir = ''; h.classList.remove('asc','desc'); });
    th.dataset.dir = asc ? 'asc' : 'desc';
    th.classList.add(asc ? 'asc' : 'desc');

    const rows = Array.from(tbody.querySelectorAll('tr'));
    rows.sort((a, b) => {
        const cells = type === 'indexed'
            ? [a, b].map((r, i) => ths[colIndex] ? r : null)
            : null;

        // Pega todas as th sortable e mapeia a posição real na linha
        let realCol = 0;
        let count   = 0;
        const allThs = table.querySelectorAll('thead th');
        for (let i = 0; i < allThs.length; i++) {
            if (allThs[i].classList.contains('sortable-th')) {
                if (count === colIndex) { realCol = i; break; }
                count++;
            }
        }

        let va = a.cells[realCol]?.textContent.trim() || '';
        let vb = b.cells[realCol]?.textContent.trim() || '';

        if (type === 'number') {
            va = parseFloat(va.replace(/[^0-9.,-]/g, '').replace(',','.')) || 0;
            vb = parseFloat(vb.replace(/[^0-9.,-]/g, '').replace(',','.')) || 0;
            return asc ? va - vb : vb - va;
        }
        if (type === 'date') {
            // formato dd/MM/yyyy HH:mm
            const toDate = s => {
                const [d, rest] = s.split(' ');
                if (!d) return 0;
                const [day, mon, yr] = d.split('/');
                return new Date(`${yr}-${mon}-${day} ${rest||'00:00'}`).getTime();
            };
            return asc ? toDate(va) - toDate(vb) : toDate(vb) - toDate(va);
        }
        return asc ? va.localeCompare(vb, 'pt-BR', {sensitivity:'base'})
                   : vb.localeCompare(va, 'pt-BR', {sensitivity:'base'});
    });
    rows.forEach(r => tbody.appendChild(r));
}
</script>
