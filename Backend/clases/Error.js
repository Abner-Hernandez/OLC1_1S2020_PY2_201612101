
class Error {

    constructor(_value,_tipo,_row,_column) {
        this.value = _value;
        this.type = _tipo;
        this.row = _row;
        this.column = _column;
    }
}

module.exports = Error;