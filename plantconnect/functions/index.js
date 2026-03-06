import functions from "firebase-functions";
import admin from "firebase-admin";
import cors from "cors";

admin.initializeApp();

const corsHandler = cors({ origin: true });

/**
 * Callable Cloud Function: sayHello
 * A simple callable function that returns a greeting message
 * Can be invoked directly from Flutter
 */
export const sayHello = functions.https.onCall((data, context) => {
  const name = data.name || "User";
  console.log(`Hello called with name: ${name}`);
  return {
    message: `Hello, ${name}! Welcome to PlantConnect 🌱`,
    timestamp: new Date().toISOString(),
  };
});

/**
 * Callable Cloud Function: processPlantData
 * Process plant information and store derived data
 */
export const processPlantData = functions.https.onCall(async (data, context) => {
  try {
    const { plantName, waterFrequency, sunlight } = data;

    if (!plantName) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Plant name is required"
      );
    }

    // Validate input data
    if (!waterFrequency || !sunlight) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Water frequency and sunlight information are required"
      );
    }

    console.log(`Processing plant data: ${plantName}`);

    // Simulate some processing
    const careLevel =
      waterFrequency === "daily" && sunlight === "full sun"
        ? "medium"
        : "easy";

    return {
      success: true,
      plantName: plantName,
      careLevel: careLevel,
      estimatedGrowthTime: "30-60 days",
      tips: [
        `Water your ${plantName} ${waterFrequency}`,
        `Place in ${sunlight}`,
        `Monitor soil moisture regularly`,
      ],
      processedAt: new Date().toISOString(),
    };
  } catch (error) {
    console.error("Error processing plant data:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * Firestore Trigger: newUserCreated
 * Automatically triggered when a new user document is created
 * Sets initial plant collection and user metadata
 */
export const newUserCreated = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    try {
      const userId = context.params.userId;
      const userData = snap.data();

      console.log(`New user created with ID: ${userId}`);
      console.log(`User data: ${JSON.stringify(userData)}`);

      // Add timestamp to user document
      await snap.ref.update({
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        userLevel: "beginner",
        totalPlants: 0,
      });

      // Create initial plant guide subcollection
      await snap.ref.collection("plantGuides").doc("welcome").set({
        title: "Welcome to PlantConnect",
        description: "Guide to getting started with plant care",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Initialization completed for user: ${userId}`);
      return null;
    } catch (error) {
      console.error("Error in newUserCreated:", error);
      throw error;
    }
  });

/**
 * Firestore Trigger: onPlantAdded
 * Automatically triggered when a new plant is added to user's collection
 * Updates user statistics and sends notifications
 */
export const onPlantAdded = functions.firestore
  .document("users/{userId}/plants/{plantId}")
  .onCreate(async (snap, context) => {
    try {
      const { userId, plantId } = context.params;
      const plantData = snap.data();

      console.log(`New plant added for user ${userId}: ${plantId}`);
      console.log(`Plant data: ${JSON.stringify(plantData)}`);

      // Update user's total plant count
      const userRef = admin.firestore().collection("users").doc(userId);
      await userRef.update({
        totalPlants: admin.firestore.FieldValue.increment(1),
        lastPlantAddedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Add plant metadata
      await snap.ref.update({
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
        healthStatus: "healthy",
        lastWatered: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(
        `Plant statistics updated for user: ${userId}, Total plants: incremented`
      );
      return null;
    } catch (error) {
      console.error("Error in onPlantAdded:", error);
      throw error;
    }
  });

/**
 * HTTP Trigger: generateCareSchedule
 * Generates a care schedule for multiple plants
 */
export const generateCareSchedule = functions.https.onRequest(
  (req, res) => {
    corsHandler(req, res, () => {
      try {
        const { plants } = req.body;

        if (!plants || !Array.isArray(plants)) {
          return res.status(400).json({
            error: "Plants array is required",
          });
        }

        const schedule = plants.map((plant) => ({
          name: plant.name,
          wateringDays: ["Monday", "Wednesday", "Friday"],
          fertilizingFrequency: "monthly",
          pruningFrequency: "quarterly",
          sunExposureHours: 6,
        }));

        res.json({
          success: true,
          schedule: schedule,
          generatedAt: new Date().toISOString(),
        });
      } catch (error) {
        console.error("Error generating care schedule:", error);
        res.status(500).json({
          error: "Failed to generate care schedule",
          details: error.message,
        });
      }
    });
  }
);
