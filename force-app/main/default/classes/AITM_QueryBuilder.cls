public virtual class AITM_QueryBuilder {

    private static final String QUERY_SEPARATOR = ', ';
    private String query;

    public AITM_QueryBuilder() {
        query = '';
    }

    public String getQuery() {
        return query;
    }

    public void selectx(Set<String> fieldList) {
        if (String.isNotBlank(query)) {
            query += QUERY_SEPARATOR;
        } else {
            query += 'SELECT ';
        }
        query += String.join(new List<String>(fieldList), QUERY_SEPARATOR);
    }

    public void selectx(String selectString) {
        if (String.isNotBlank(query)) {
            query += QUERY_SEPARATOR;
        }
        query += ' ' + String.escapeSingleQuotes(selectString);
    }

    public void fromx(String objectName) {
        query += ' FROM ' + String.escapeSingleQuotes(objectName);
    }

    public void wherex(String criteria) {
        query += ' WHERE ' + criteria;
    }

    public void wherex(String criteria, String logicalOperator) {
        query += ' ' + logicalOperator + ' ' + criteria;
    }

    public void orderbyx(String fieldName, String direction) {
        query += ' ORDER BY ' + fieldName + ' ' + direction; 
    }
	
    public void limitx(String limitInteger) {
        query += ' LIMIT ' + limitInteger; 
    }
}