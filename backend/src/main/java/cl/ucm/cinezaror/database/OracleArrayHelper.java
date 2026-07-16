package cl.ucm.cinezaror.database;

import oracle.jdbc.OracleConnection;
import org.springframework.jdbc.core.SqlTypeValue;

import java.sql.Array;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

public final class OracleArrayHelper {

    private OracleArrayHelper() {
    }

    public static SqlTypeValue numberListType(String typeName, List<Long> values) {
        return (PreparedStatement ps, int paramIndex, int sqlType, String typeNameParam) -> {
            Connection connection = ps.getConnection();
            OracleConnection oracleConnection = connection.unwrap(OracleConnection.class);
            Array array = oracleConnection.createOracleArray(typeName, values.toArray(new Long[0]));
            ps.setArray(paramIndex, array);
        };
    }
}
