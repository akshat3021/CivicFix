package validators;


public class ComplaintValidator {

    public static String validate(
            String title,
            String description,
            String category
    ) {
        String error;

        error = TitleValidator.validate(title);
        if (error != null) return error;

        error = DescriptionValidator.validate(description);
        if (error != null) return error;

        error = CategoryValidator.validate(category);
        if (error != null) return error;

        return null; // everything valid
    }
}
