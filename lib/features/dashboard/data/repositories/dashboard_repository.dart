import '../../../ticket/data/repositories/ticket_repository.dart';
import '../../../ticket/data/models/ticket_model.dart';
// DASHBOARD REPOSITORY:
// Digunakan untuk menghitung statistik tiket (Open, Pending, Closed) yang ditampilkan pada halaman dashboard.
class DashboardRepository {
  // Kita menggunakan `TicketRepository` untuk memanggil fungsi getTickets() yang mengambil data dari tabel `tickets`.
  final TicketRepository ticketRepository = TicketRepository();

  // 1. FUNGSI HITUNG STATISTIK (GET DASHBOARD STATS):
  // Cara kerjanya:
  // - Pertama, nembak API Supabase menggunakan `ticketRepository.getTickets()` untuk mengambil semua tiket yang bisa diakses user tersebut.
  // - Kedua, melakukan pemfilteran lokal (.where) di sisi aplikasi untuk menghitung jumlah tiket dengan status "Open", "Pending", dan "Closed".
  // - Ketiga, mengembalikan data Map JSON statistik tersebut ke UI/Dashboard screen.
  Future<Map<String, int>> getDashboardStats() async {

    List<TicketModel> tickets = await ticketRepository.getTickets();

    int open = tickets.where((t) => t.status == "Open").length;
    int pending = tickets.where((t) => t.status == "Pending").length;
    int closed = tickets.where((t) => t.status == "Closed").length;

    return {
      "open": open,
      "pending": pending,
      "closed": closed,
      "total": tickets.length,
    };
  }

}