package validators;

    
import java.util.Arrays;
import java.util.List;

public class CategoryValidator {

    private static final List<String> VALID_CATEGORIES = Arrays.asList(
            "Road",
            "Electricity",
            "Water",
            "Garbage",
            "Public Safety",
            "Other"
    );

    public static String validate(String category) {
        if (category == null || !VALID_CATEGORIES.contains(category)) {
            return "Invalid category selected";
        }

        return null;
    }
}

