package validators;

public class DescriptionValidator {

    public static String validate(String description) {
        if (description == null || description.trim().length() < 20) {
            return "Description must be at least 20 characters long";
        }

        return null;
    }
}
