import LLM "mo:llm";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Array "mo:base/Array"; // Tambahkan impor untuk Array

actor NewsVerification {
    type VerificationResult = {
        news: Text;
        result: Text;
    };

    type Feedback = {
        resultId: Nat;
        rating: Nat; // Rating dari 1-5
    };

    var verificationHistory: [VerificationResult] = [];
    var feedbackList: [Feedback] = [];

    public func verifyNews(news: Text) : async Text {
        // Validasi input tidak boleh kosong
        if (Text.size(news) == 0) {
            return "{\"error\": \"Berita tidak boleh kosong.\"}";
        };

        let verificationPrompt = 
            "Analisis berita berikut dan tentukan apakah itu hoax atau fakta.\n" #
            "Jika berita adalah hoax, berikan ringkasan berita yang benar.\n" #
            "Jawaban harus dalam format JSON berikut:\n" #
            "{\n" #
            "  \"status\": \"Hoax/Fakta\",\n" #
            "  \"rating_kepercayaan\": \"(0-100)%\",\n" #
            "  \"kesimpulan\": \"Ringkasan singkat\",\n" #
            "  \"berita_benar\": \"Ringkasan berita yang benar jika hoax, kosong jika fakta\"\n" #
            "}\n\n" #
            "Berita: " # news;

        let result = await LLM.prompt(#Llama3_1_8B, verificationPrompt);

        // Simpan hasil verifikasi ke dalam riwayat
        let verificationResult: VerificationResult = {
            news = news;
            result = result;
        };
        verificationHistory := Array.append(verificationHistory, [verificationResult]);

        // Debug output untuk memastikan format respons dari LLM
        Debug.print("LLM Response: " # result);

        return result;
    };

    public func getVerificationHistory() : async [VerificationResult] {
        return verificationHistory;
    };

    public func submitFeedback(resultId: Nat, rating: Nat) : async Text {
        if (rating < 1 or rating > 5) {
            return "{\"error\": \"Rating harus antara 1 dan 5.\"}";
        };

        feedbackList := Array.append(feedbackList, [{ resultId = resultId; rating = rating }]);
        return "{\"success\": \"Feedback diterima.\"}";
    };
};