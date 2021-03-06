use query::Query;
use dao::Dao;

use dao::Value;
use database::Database;
use writer::SqlFrag;
use database::{SqlOption, BuildMode};

use mysql::value::Value as MyValue;
use mysql::consts::ColumnType;
use mysql::value::FromValue;
use mysql::value::IntoValue;
use mysql::error::MyResult;
use mysql::conn::Stmt;
use mysql::conn::pool::MyPool;
use chrono::naive::datetime::NaiveDateTime;

use table::Table;
use database::DatabaseDDL;
use database::DbError;
use time::Timespec;
use dao::Type;

pub struct Mysql {
    pool: Option<MyPool>,
}
impl Mysql{
    pub fn new() -> Self {
        Mysql { pool: None }
    }

    pub fn with_pooled_connection(pool: MyPool) -> Self {
        Mysql { pool: Some(pool) }
    }

    fn from_rust_type_tosql(types: &[Value]) -> Vec<MyValue> {
        let mut params: Vec<MyValue> = vec![];
        for t in types {
            match *t {
                Value::Bool(ref x) => {
                    let v = x.into_value();
                    params.push(v);
                },
                Value::String(ref x) => {
                    params.push(MyValue::Bytes(x.as_bytes().to_owned()));
                },
                Value::I8(ref x) => {
                    let v = x.into_value();
                    params.push(v);
                },
                 Value::I16(ref x) => {
                    let v = x.into_value();
                    params.push(v);
                },
                Value::I32(ref x) => {
                    let v = x.into_value();
                    params.push(v);
                },
                Value::I64(ref x) => {
                    let v = x.into_value();
                    params.push(v);
                },
                Value::U8(ref x) => {
                    let v = x.into_value();
                    params.push(v);
                },
                Value::U32(ref x) => {
                    let v = x.into_value();
                    params.push(v);
                },
                Value::U64(ref x) => {
                    let v = x.into_value();
                    params.push(v);
                },
                Value::F32(ref x) => {
                    let v = x.into_value();
                    params.push(v);
                },
                Value::F64(ref x) => {
                    let v = x.into_value();
                    params.push(v);
                },
                _ => panic!("not yet here {:?}", t),
            }
        }
        params
    }

    /// convert a record of a row into rust type
    fn from_sql_to_rust_type(row: &[MyValue], index: usize, column_type: &ColumnType) -> Value {
        let value = row.get(index);
        match value {
            Some(value) => {
                    println!("sql to rust {:?} type: {:?}", value, column_type);
                    match *value{
                        MyValue::NULL => {
                            Value::None(Type::String)// should put Type::Unknown
                        },
                        
                        _ => {
                            match *column_type{
                                ColumnType::MYSQL_TYPE_DECIMAL => {
                                    let v: f64 = FromValue::from_value(value.clone());
                                    Value::F64(v)
                                },
                                ColumnType::MYSQL_TYPE_TINY =>{
                                    let v: i8 = FromValue::from_value(value.clone());
                                    Value::I8(v)
                                },
                                ColumnType::MYSQL_TYPE_SHORT => {
                                    let v: i16 = FromValue::from_value(value.clone());
                                    Value::I16(v)
                                },
                                ColumnType::MYSQL_TYPE_LONG => {
                                    let v: i64 = FromValue::from_value(value.clone());
                                    Value::I64(v)
                                },
                                ColumnType::MYSQL_TYPE_FLOAT =>{
                                    let v: f32 = FromValue::from_value(value.clone());
                                    Value::F32(v)
                                },
                                ColumnType::MYSQL_TYPE_DOUBLE => {
                                    let v: f64 = FromValue::from_value(value.clone());
                                    Value::F64(v)
                                },
                                ColumnType::MYSQL_TYPE_NULL => Value::None(Type::String),
                                ColumnType::MYSQL_TYPE_TIMESTAMP => {
                                    let v: Timespec = FromValue::from_value(value.clone());
                                    let t = NaiveDateTime::from_timestamp(v.sec, v.nsec as u32);
                                    println!("time: {}",t);
                                    Value::NaiveDateTime(t)
                                },
                                ColumnType::MYSQL_TYPE_LONGLONG =>  {
                                    let v: i64 = FromValue::from_value(value.clone());
                                    Value::I64(v)
                                },
                                ColumnType::MYSQL_TYPE_INT24 => {
                                    let v: i32 = FromValue::from_value(value.clone());
                                    Value::I32(v)
                                },
                                ColumnType::MYSQL_TYPE_DATE => {
                                    let v: Timespec = FromValue::from_value(value.clone());
                                    let t = NaiveDateTime::from_timestamp(v.sec, v.nsec as u32);
                                    Value::NaiveDateTime(t)
                                },
                                ColumnType::MYSQL_TYPE_TIME => {
                                    let v: Timespec = FromValue::from_value(value.clone());
                                    let t = NaiveDateTime::from_timestamp(v.sec, v.nsec as u32);
                                    Value::NaiveDateTime(t)
                                },
                                ColumnType::MYSQL_TYPE_DATETIME => {
                                    let v: Timespec = FromValue::from_value(value.clone());
                                    let t = NaiveDateTime::from_timestamp(v.sec, v.nsec as u32);
                                    Value::NaiveDateTime(t)
                                },
                                ColumnType::MYSQL_TYPE_YEAR => {
                                    let v: Timespec = FromValue::from_value(value.clone());
                                    let t = NaiveDateTime::from_timestamp(v.sec, v.nsec as u32);
                                    Value::NaiveDateTime(t)
                                },
                                ColumnType::MYSQL_TYPE_VARCHAR => {
                                    let v: String = FromValue::from_value(value.clone());
                                    Value::String(v)
                                },
                                ColumnType::MYSQL_TYPE_BIT =>unimplemented!(),
                                ColumnType::MYSQL_TYPE_NEWDECIMAL => {
                                    let v: f64 = FromValue::from_value(value.clone());
                                    Value::F64(v)
                                },
                                ColumnType::MYSQL_TYPE_ENUM => {
                                    let v: String = FromValue::from_value(value.clone());
                                    Value::String(v)
                                },
                                ColumnType::MYSQL_TYPE_SET => {
                                    let v: String = FromValue::from_value(value.clone());
                                    Value::String(v)
                                },
                                ColumnType::MYSQL_TYPE_TINY_BLOB => {
                                    let v: String = FromValue::from_value(value.clone());
                                    Value::String(v)
                                },
                                ColumnType::MYSQL_TYPE_MEDIUM_BLOB => {
                                    let v: String = FromValue::from_value(value.clone());
                                    Value::String(v)
                                },
                                ColumnType::MYSQL_TYPE_LONG_BLOB => {
                                    let v: String = FromValue::from_value(value.clone());
                                    Value::String(v)
                                },
                                ColumnType::MYSQL_TYPE_BLOB => {
                                    let v: String = FromValue::from_value(value.clone());
                                    Value::String(v)
                                },
                                ColumnType::MYSQL_TYPE_VAR_STRING => {
                                    let v: String = FromValue::from_value(value.clone());
                                    Value::String(v)
                                },
                                ColumnType::MYSQL_TYPE_STRING => {
                                    let v: String = FromValue::from_value(value.clone());
                                    Value::String(v)
                                },
                                ColumnType::MYSQL_TYPE_GEOMETRY => {
                                    let v: String = FromValue::from_value(value.clone());
                                    Value::String(v)
                                },
                            }
                        }
                    }
                    
                },
            None => Value::None(Type::String),
        }
    }

    ///
    /// convert rust data type names to database data type names
    /// will be used in generating SQL for table creation
    /// FIXME, need to restore the exact data type as before
    fn rust_type_to_dbtype(&self, rust_type: &Type) -> String {
        match *rust_type {
            Type::Bool => {
                "bool".to_owned()
            }
            Type::I8 => {
                "tinyint(1)".to_owned()
            }
            Type::I16 => {
                "integer".to_owned()
            }
            Type::I32 => {
                "integer".to_owned()
            }
            Type::U32 => {
                "integer".to_owned()
            }
            Type::I64 => {
                "integer".to_owned()
            }
            Type::F32 => {
                "real".to_owned()
            }
            Type::F64 => {
                "real".to_owned()
            }
            Type::String => {
                "text".to_owned()
            }
            Type::VecU8 => {
                "blob".to_owned()
            }
            Type::Json => {
                "text".to_owned()
            }
            Type::Uuid => {
                "varchar(36)".to_owned()
            }
            Type::NaiveDateTime => {
                "timestamp".to_owned()
            }
            Type::DateTime => {
                "timestamp".to_owned()
            }
            Type::NaiveDate => {
                "date".to_owned()
            }
            Type::NaiveTime => {
                "time".to_owned()
            }
            _ => panic!("Unable to get the equivalent database data type for {:?}",
                        rust_type),
        }
    }

    fn get_prepared_statement<'a>(&'a self, sql: &'a str) -> MyResult<Stmt> {
        self.pool.as_ref().unwrap().prepare(sql)
    }
}

impl Database for Mysql {
    fn version(&self) -> Result<String, DbError> {
        let sql = "SELECT version()";
        let dao = try!(self.execute_sql_with_one_return(sql, &vec![]));
        match dao {
            Some(dao) => Ok(dao.get("version")),
            None => Err(DbError::new("Unable to get database version")),
        }
    }

    fn begin(&self) {
        unimplemented!()
    }
    fn commit(&self) {
        unimplemented!()
    }
    fn rollback(&self) {
        unimplemented!()
    }
    fn is_transacted(&self) -> bool {
        false
    }
    fn is_closed(&self) -> bool {
        false
    }
    fn is_connected(&self) -> bool {
        false
    }
    fn close(&self) {
    }
    fn is_valid(&self) -> bool {
        false
    }
    fn reset(&self) {
        unimplemented!()
    }

    /// return this list of options, supported features in the database
    fn sql_options(&self) -> Vec<SqlOption> {
        vec![
            SqlOption::UsesQuestionMark,//mysql uses question mark instead of the numbered params
        ]
    }

    fn update(&self, _query: &Query) -> Dao {
        unimplemented!()
    }
    fn delete(&self, _query: &Query) -> Result<usize, String> {
        unimplemented!()
    }

    fn execute_sql_with_return(&self, sql: &str, params: &[Value]) -> Result<Vec<Dao>, DbError> {
        println!("SQL: \n{}", sql);
        println!("param: {:?}", params);
        assert!(self.pool.is_some());
        let mut stmt = try!(self.get_prepared_statement(sql));
        let mut columns = vec![];
        for col in stmt.columns_ref().unwrap() {
            let column_name = String::from_utf8(col.name.clone()).unwrap();
            println!("column type: {:?}", col.column_type);
            columns.push( (column_name, col.column_type) );
        }
        let mut daos = vec![];
        let param = Mysql::from_rust_type_tosql(params);
        let rows = try!(stmt.execute(&param));
        for row in rows {
            let row = try!(row);
            let mut index = 0;
            let mut dao = Dao::new();
            for &(ref column_name, ref column_type) in &columns {
                let rtype = Mysql::from_sql_to_rust_type(&row, index, column_type);
                dao.set_value(&column_name, rtype);
                index += 1;
            }
            daos.push(dao);
        }
        Ok(daos)
    }

    fn execute_sql_with_one_return(&self,
                                   sql: &str,
                                   params: &[Value])
                                   -> Result<Option<Dao>, DbError> {
        let dao = try!(self.execute_sql_with_return(sql, params));
        if dao.len() >= 1 {
            Ok(Some(dao[0].clone()))
        } else {
            Ok(None)
        }
    }

    /// generic execute sql which returns not much information,
    /// returns only the number of affected records or errors
    /// can be used with DDL operations (CREATE, DELETE, ALTER, DROP)
    fn execute_sql(&self, sql: &str, params: &[Value]) -> Result<usize, DbError> {
        println!("SQL: \n{}", sql);
        println!("param: {:?}", params);
        let to_sql_types = Mysql::from_rust_type_tosql(params);
        assert!(self.pool.is_some());
        let result = try!(self.pool.as_ref().unwrap().prep_exec(sql, &to_sql_types));
        Ok(result.affected_rows() as usize)
    }

}

impl DatabaseDDL for Mysql{
    fn create_schema(&self, _schema: &str) {
        unimplemented!()
    }

    fn drop_schema(&self, _schema: &str) {
        unimplemented!()
    }

    fn build_create_table(&self, table: &Table) -> SqlFrag {
        let mut w = SqlFrag::new(self.sql_options(), BuildMode::Standard);
        w.append("CREATE TABLE ");
        w.append(&table.name);
        w.append("(");
        w.ln_tab();
        let mut do_comma = false;
        for c in &table.columns {
            if do_comma {
                w.commasp();
            } else {
                do_comma = true;
            }
            w.append(&c.name);
            w.append(" ");
            let dt = self.rust_type_to_dbtype(&c.data_type);
            w.append(&dt);
            if c.is_primary {
                w.append(" PRIMARY KEY ");
            }
        }
        w.append(")");
        w
    }
    fn create_table(&self, table: &Table) {
        let frag = self.build_create_table(table);
        match self.execute_sql(&frag.sql, &vec![]) {
            Ok(_) => println!("created table.."),
            Err(e) => panic!("table not created {}", e),
        }
    }

    fn rename_table(&self, _table: &Table, _new_tablename: String) {
        unimplemented!()
    }

    fn drop_table(&self, _table: &Table) {
        unimplemented!()
    }

    fn set_foreign_constraint(&self, _model: &Table) {
        unimplemented!()
    }

    fn set_primary_constraint(&self, _model: &Table) {
        unimplemented!()
    }
}


// TODO: need to implement trait DatabaseDev for Mysql
// Mysql can be used as development database
