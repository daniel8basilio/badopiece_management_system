export function startOfDay(date) {
    if(!date) {
        return null;
    }
    return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}
