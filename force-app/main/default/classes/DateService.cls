public virtual class DateService {
    public virtual Integer getCurrentMonth() {
        return System.today().month();
    }

    public virtual Date getToday() {
        return System.today();
    }
}