import Foundation

nonisolated struct MovementGuide: Sendable, Hashable {
    let whatIsIt: String
    let howTo: [String]
    let alternatives: [String]
    let tips: [String]
    let primaryMuscles: String?

    init(
        whatIsIt: String,
        howTo: [String],
        alternatives: [String],
        tips: [String] = [],
        primaryMuscles: String? = nil
    ) {
        self.whatIsIt = whatIsIt
        self.howTo = howTo
        self.alternatives = alternatives
        self.tips = tips
        self.primaryMuscles = primaryMuscles
    }
}

enum MovementGuideLibrary {

    static func guide(for name: String) -> MovementGuide {
        let key = name.lowercased()
        for entry in entries {
            if entry.patterns.contains(where: { key.contains($0) }) {
                return entry.guide
            }
        }
        return generic
    }

    static func hasGuide(for name: String) -> Bool {
        let key = name.lowercased()
        if entries.contains(where: { entry in entry.patterns.contains(where: { key.contains($0) }) }) {
            return true
        }
        return CardioGuideLibrary.hasGuide(for: name)
    }

    private struct Entry {
        let patterns: [String]
        let guide: MovementGuide
    }

    private static let generic = MovementGuide(
        whatIsIt: "A conditioning movement used to build strength, stamina, or coordination.",
        howTo: [
            "Set up in a stable, athletic stance with core braced.",
            "Move through the full range of motion under control.",
            "Breathe on the exertion and reset between reps."
        ],
        alternatives: [
            "Slow the pace and reduce load or reps.",
            "Substitute a similar bodyweight variation.",
            "Break the set into smaller clusters with short rest."
        ]
    )

    private static let entries: [Entry] = [
        // Running / Cardio terms
        Entry(patterns: ["sprint"], guide: MovementGuide(
            whatIsIt: "Short, near-maximal efforts to build speed and power.",
            howTo: [
                "Warm up thoroughly with easy jogging and strides.",
                "Drive knees up and pump arms in a straight line.",
                "Sprint all-out for the prescribed distance, then fully recover."
            ],
            alternatives: ["Hill strides", "Bike sprints", "Fast tempo intervals"]
        )),
        Entry(patterns: ["run", "jog"], guide: MovementGuide(
            whatIsIt: "Continuous running at the prescribed effort for the given distance or time.",
            howTo: [
                "Keep posture tall, eyes up, shoulders relaxed.",
                "Land softly under your hips with a quick cadence.",
                "Pace yourself — you should be able to finish the full distance."
            ],
            alternatives: ["Brisk walk", "Stationary bike", "Elliptical at moderate effort"]
        )),
        Entry(patterns: ["walk", "ruck"], guide: MovementGuide(
            whatIsIt: "Low-impact aerobic movement for endurance and recovery.",
            howTo: [
                "Walk tall with a natural arm swing.",
                "Roll heel to toe and keep a brisk, purposeful pace.",
                "Breathe rhythmically through nose and mouth."
            ],
            alternatives: ["Elliptical", "Stationary bike", "Treadmill incline walk"]
        )),
        Entry(patterns: ["row"], guide: MovementGuide(
            whatIsIt: "A full-body pulling movement — on the erg or with weights — that trains the back.",
            howTo: [
                "Drive with the legs first, then hinge the hips, then pull with the arms.",
                "Keep the chest up and shoulders down away from the ears.",
                "Return in reverse: arms, hips, then legs under control."
            ],
            alternatives: ["Seated cable row", "Dumbbell bent-over row", "Inverted row"]
        )),

        // Carries
        Entry(patterns: ["farmer", "suitcase", "carry"], guide: MovementGuide(
            whatIsIt: "Weighted walk that trains grip, core stability, and posture.",
            howTo: [
                "Pick up the load with a neutral spine and braced core.",
                "Stand tall, ribs down, and walk with smooth, even steps.",
                "Set the load down with the same hinge pattern you used to pick it up."
            ],
            alternatives: ["Heavy backpack walk", "Single dumbbell suitcase carry", "Kettlebell rack carry"]
        )),

        // Squats
        Entry(patterns: ["goblet squat"], guide: MovementGuide(
            whatIsIt: "A front-loaded squat holding a dumbbell or kettlebell at the chest.",
            howTo: [
                "Hold the weight at your chest with elbows tucked.",
                "Sit down between your hips, knees tracking over toes.",
                "Drive through the whole foot to stand tall."
            ],
            alternatives: ["Bodyweight squat", "Box squat", "Dumbbell squat"]
        )),
        Entry(patterns: ["back squat", "squat"], guide: MovementGuide(
            whatIsIt: "A fundamental lower-body strength movement.",
            howTo: [
                "Brace your core and set the bar or weight securely.",
                "Sit back and down until thighs reach at least parallel.",
                "Drive through mid-foot and stand tall with hips and knees locked out."
            ],
            alternatives: ["Goblet squat", "Box squat", "Bodyweight squat"]
        )),
        Entry(patterns: ["bulgarian split"], guide: MovementGuide(
            whatIsIt: "Rear-foot-elevated split squat that trains one leg at a time.",
            howTo: [
                "Place your back foot on a bench with front foot a stride length ahead.",
                "Lower straight down until the back knee nearly touches the floor.",
                "Drive through the front foot to return to standing."
            ],
            alternatives: ["Reverse lunge", "Step-up", "Split squat"]
        )),
        Entry(patterns: ["lunge"], guide: MovementGuide(
            whatIsIt: "A single-leg squat pattern for leg strength and balance.",
            howTo: [
                "Step forward or backward into a stride position.",
                "Lower straight down until the back knee gently touches the floor.",
                "Drive through the front foot to return to standing."
            ],
            alternatives: ["Split squat", "Step-up", "Goblet squat"]
        )),

        // Deadlifts / hinge
        Entry(patterns: ["romanian deadlift", "rdl"], guide: MovementGuide(
            whatIsIt: "A hip-hinge deadlift variation that emphasizes the hamstrings and glutes.",
            howTo: [
                "Hold the bar or dumbbells at your hips with a slight knee bend.",
                "Push hips straight back, keeping the bar close to your legs.",
                "Lower until you feel a stretch, then drive hips forward to stand tall."
            ],
            alternatives: ["Kettlebell swing", "Hip bridge", "Good morning"]
        )),
        Entry(patterns: ["sumo deadlift"], guide: MovementGuide(
            whatIsIt: "A deadlift with a wide stance that recruits more hip and quad.",
            howTo: [
                "Set feet wider than shoulder width with toes slightly out.",
                "Grip the bar inside your knees, chest up, hips low.",
                "Stand tall by driving the floor away, hips and shoulders rising together."
            ],
            alternatives: ["Conventional deadlift", "Kettlebell deadlift", "Trap bar deadlift"]
        )),
        Entry(patterns: ["hex bar deadlift", "trap bar"], guide: MovementGuide(
            whatIsIt: "Deadlift performed inside a hex/trap bar with neutral grip — easier on the back.",
            howTo: [
                "Stand inside the bar with feet under your hips.",
                "Hinge to grip handles, chest up, lats engaged.",
                "Drive the floor down and stand tall, then lower with control."
            ],
            alternatives: ["Kettlebell deadlift", "Dumbbell deadlift", "Romanian deadlift"]
        )),
        Entry(patterns: ["deadlift"], guide: MovementGuide(
            whatIsIt: "A hip-hinge pulling movement that trains the entire posterior chain.",
            howTo: [
                "Set feet hip-width, bar over mid-foot.",
                "Hinge to grip the bar with flat back and braced core.",
                "Stand tall by driving through the floor, keeping the bar close."
            ],
            alternatives: ["Trap bar deadlift", "Dumbbell RDL", "Kettlebell deadlift"]
        )),
        Entry(patterns: ["good morning"], guide: MovementGuide(
            whatIsIt: "A hip-hinge movement that loads the hamstrings and lower back.",
            howTo: [
                "Bar or weight across upper back, feet hip-width.",
                "Hinge at the hips with a soft knee bend, chest proud.",
                "Return by squeezing glutes and standing tall."
            ],
            alternatives: ["Romanian deadlift", "Back extension", "Hip bridge"]
        )),
        Entry(patterns: ["hip thrust", "hip bridge", "glute bridge"], guide: MovementGuide(
            whatIsIt: "A glute-dominant hip extension movement.",
            howTo: [
                "Shoulders on a bench or floor, feet flat, knees bent.",
                "Drive hips up until body forms a straight line from knees to shoulders.",
                "Squeeze glutes hard at the top, then lower with control."
            ],
            alternatives: ["Glute bridge", "Single-leg bridge", "Cable pull-through"]
        )),
        Entry(patterns: ["kettlebell swing", "kb swing"], guide: MovementGuide(
            whatIsIt: "An explosive hip hinge that drives a kettlebell from between the legs to chest height.",
            howTo: [
                "Hinge at the hips to send the bell back between your legs.",
                "Snap hips forward explosively — the bell floats up from hip drive.",
                "Let it fall naturally and catch it with another hip hinge."
            ],
            alternatives: ["Dumbbell swing", "Romanian deadlift", "Hip thrust"]
        )),

        // Push
        Entry(patterns: ["bench press"], guide: MovementGuide(
            whatIsIt: "Horizontal pushing strength movement for the chest, shoulders, and triceps.",
            howTo: [
                "Set shoulders down and back on the bench, feet planted.",
                "Lower the bar under control to mid-chest.",
                "Press the bar back up while keeping shoulder blades pinched."
            ],
            alternatives: ["Dumbbell bench press", "Push-up", "Floor press"]
        )),
        Entry(patterns: ["incline"], guide: MovementGuide(
            whatIsIt: "A pressing variation on an inclined bench that emphasizes the upper chest.",
            howTo: [
                "Set bench around 30–45°.",
                "Lower the weight to the upper chest under control.",
                "Press up and slightly back, keeping shoulders stable."
            ],
            alternatives: ["Flat dumbbell press", "Incline push-up", "Landmine press"]
        )),
        Entry(patterns: ["overhead press", "ohp", "arnold press", "shoulder press"], guide: MovementGuide(
            whatIsIt: "A vertical pressing movement for the shoulders and triceps.",
            howTo: [
                "Start with the weight at shoulder height, core braced.",
                "Press overhead in a straight line, ribs down, glutes tight.",
                "Lower under control to the starting position."
            ],
            alternatives: ["Seated dumbbell press", "Landmine press", "Push press"]
        )),
        Entry(patterns: ["push press"], guide: MovementGuide(
            whatIsIt: "An overhead press assisted by a shallow leg drive.",
            howTo: [
                "Start in the front rack, feet under hips.",
                "Dip by bending knees slightly, then drive up hard.",
                "Press the weight to lockout overhead."
            ],
            alternatives: ["Strict press", "Dumbbell push press", "Landmine push press"]
        )),
        Entry(patterns: ["lateral raise"], guide: MovementGuide(
            whatIsIt: "A shoulder isolation movement that targets the side delts.",
            howTo: [
                "Stand tall with light dumbbells at your sides.",
                "Raise arms out to shoulder height with slight elbow bend.",
                "Lower under control — no swinging."
            ],
            alternatives: ["Cable lateral raise", "Band lateral raise", "Upright row"]
        )),
        Entry(patterns: ["hand-release push", "hand release push"], guide: MovementGuide(
            whatIsIt: "A push-up where the chest touches the floor and hands lift briefly at the bottom.",
            howTo: [
                "Plank position, hands under shoulders.",
                "Lower all the way to the floor and lift hands briefly.",
                "Replace hands and press back up to plank."
            ],
            alternatives: ["Knee push-up", "Incline push-up", "Standard push-up"]
        )),
        Entry(patterns: ["diamond push", "close-grip push"], guide: MovementGuide(
            whatIsIt: "A push-up variation with hands close together to emphasize the triceps.",
            howTo: [
                "Place hands close under your chest, thumbs and index fingers touching.",
                "Lower with elbows tracking back along your ribs.",
                "Press up without letting the hips sag."
            ],
            alternatives: ["Tricep dip", "Close-grip bench", "Standard push-up"]
        )),
        Entry(patterns: ["push-up", "push up", "pushup"], guide: MovementGuide(
            whatIsIt: "A bodyweight pressing movement for the chest, shoulders, and core.",
            howTo: [
                "Plank position, hands under shoulders, body in a straight line.",
                "Lower your chest to the floor with elbows at ~45°.",
                "Press back up without letting the hips sag or rise."
            ],
            alternatives: ["Knee push-up", "Incline push-up", "Wall push-up"]
        )),
        Entry(patterns: ["dip"], guide: MovementGuide(
            whatIsIt: "A bodyweight pressing movement on parallel bars or a bench.",
            howTo: [
                "Support yourself on bars or a bench with arms locked.",
                "Lower until elbows are roughly 90°.",
                "Press back up to full lockout."
            ],
            alternatives: ["Bench dip", "Close-grip push-up", "Tricep pushdown"]
        )),
        Entry(patterns: ["fly"], guide: MovementGuide(
            whatIsIt: "A chest isolation movement with a wide arcing motion.",
            howTo: [
                "Lie back with dumbbells pressed above your chest, slight elbow bend.",
                "Open arms out in a wide arc until you feel a chest stretch.",
                "Squeeze the chest to bring the weights back together."
            ],
            alternatives: ["Cable fly", "Push-up", "Pec deck"]
        )),

        // Pull
        Entry(patterns: ["pull-up", "pull up", "pullup"], guide: MovementGuide(
            whatIsIt: "A vertical pulling movement that trains the lats and upper back.",
            howTo: [
                "Hang from the bar with hands just outside shoulder width.",
                "Pull your chest toward the bar, driving elbows down and back.",
                "Lower under control to a full hang."
            ],
            alternatives: ["Band-assisted pull-up", "Inverted row", "Lat pulldown"]
        )),
        Entry(patterns: ["lat pulldown"], guide: MovementGuide(
            whatIsIt: "A cable pulldown that trains the same muscles as the pull-up.",
            howTo: [
                "Sit tall with thighs under the pad, grip bar just outside shoulders.",
                "Pull the bar to your collarbone, squeezing your back.",
                "Return under control without shrugging."
            ],
            alternatives: ["Pull-up", "Straight-arm pulldown", "Band pulldown"]
        )),
        Entry(patterns: ["pendlay row", "bent-over row", "bent over row", "barbell row"], guide: MovementGuide(
            whatIsIt: "A bent-over barbell row that builds upper back thickness.",
            howTo: [
                "Hinge forward with flat back until torso is roughly parallel to the floor.",
                "Pull the bar to your lower ribs, squeezing your shoulder blades.",
                "Lower under control without rounding your back."
            ],
            alternatives: ["Dumbbell row", "Cable row", "Chest-supported row"]
        )),
        Entry(patterns: ["face pull"], guide: MovementGuide(
            whatIsIt: "An upper-back and rear-delt movement using a rope on a cable.",
            howTo: [
                "Set the rope at upper chest height with a light weight.",
                "Pull the rope to your face, hands ending by your ears.",
                "Squeeze the rear delts, then return under control."
            ],
            alternatives: ["Band pull-apart", "Rear delt fly", "Reverse fly"]
        )),
        Entry(patterns: ["curl"], guide: MovementGuide(
            whatIsIt: "An elbow-flexion movement that isolates the biceps.",
            howTo: [
                "Stand tall with elbows pinned to your sides.",
                "Curl the weight toward your shoulders without swinging.",
                "Lower under control to a full stretch."
            ],
            alternatives: ["Hammer curl", "Cable curl", "Chin-up"]
        )),
        Entry(patterns: ["skull crusher"], guide: MovementGuide(
            whatIsIt: "A tricep isolation movement lying on a bench.",
            howTo: [
                "Lie back, press a barbell or dumbbells over your face.",
                "Bend only at the elbows, lowering the weight near your forehead.",
                "Extend back to lockout using only the triceps."
            ],
            alternatives: ["Overhead tricep extension", "Tricep pushdown", "Close-grip press"]
        )),

        // Core
        Entry(patterns: ["side plank"], guide: MovementGuide(
            whatIsIt: "A lateral core hold that trains the obliques.",
            howTo: [
                "On your side with elbow under shoulder, stack feet.",
                "Lift hips so your body forms a straight diagonal.",
                "Hold — don't let hips drop."
            ],
            alternatives: ["Kneeling side plank", "Copenhagen plank", "Side crunch"]
        )),
        Entry(patterns: ["plank"], guide: MovementGuide(
            whatIsIt: "An isometric core hold that builds total-body stability.",
            howTo: [
                "Forearms or hands under shoulders, feet hip-width.",
                "Body in a straight line — no sag, no pike.",
                "Brace the core and hold while breathing steadily."
            ],
            alternatives: ["Knee plank", "Incline plank", "Dead bug"]
        )),
        Entry(patterns: ["dead bug"], guide: MovementGuide(
            whatIsIt: "A core stability exercise performed on your back.",
            howTo: [
                "Lie on back, arms up, knees bent to 90°.",
                "Lower opposite arm and leg until just above the floor.",
                "Return under control and switch sides."
            ],
            alternatives: ["Bird dog", "Hollow hold", "Plank"]
        )),
        Entry(patterns: ["bird dog"], guide: MovementGuide(
            whatIsIt: "A quadruped anti-rotation core exercise.",
            howTo: [
                "On hands and knees, back flat, core braced.",
                "Extend opposite arm and leg until parallel to the floor.",
                "Return under control and switch sides."
            ],
            alternatives: ["Dead bug", "Plank", "Superman"]
        )),
        Entry(patterns: ["hollow"], guide: MovementGuide(
            whatIsIt: "A gymnastic core hold that trains full-body tension.",
            howTo: [
                "Lie on your back, press lower back into the floor.",
                "Lift shoulders and legs to form a dish shape.",
                "Hold tight with arms overhead — don't let the low back rise."
            ],
            alternatives: ["Dead bug", "Leg raise", "Plank"]
        )),
        Entry(patterns: ["flutter kick"], guide: MovementGuide(
            whatIsIt: "A core and hip-flexor exercise with small alternating leg kicks.",
            howTo: [
                "Lie on back, low back pressed to the floor.",
                "Lift legs a few inches and flutter them up and down.",
                "Keep the motion small and the core braced."
            ],
            alternatives: ["Dead bug", "Leg raise", "Plank"]
        )),
        Entry(patterns: ["shoulder tap"], guide: MovementGuide(
            whatIsIt: "A plank variation that challenges anti-rotation.",
            howTo: [
                "Start in a high plank, feet slightly wider for stability.",
                "Tap one hand to the opposite shoulder without rocking hips.",
                "Alternate sides under control."
            ],
            alternatives: ["Plank", "Bird dog", "Renegade row"]
        )),

        // Explosive / conditioning
        Entry(patterns: ["burpee"], guide: MovementGuide(
            whatIsIt: "A full-body conditioning movement combining a squat, plank, and jump.",
            howTo: [
                "From standing, drop your hands to the floor and kick feet back to a plank.",
                "Chest to the floor, then snap feet back under you.",
                "Stand and jump with arms overhead."
            ],
            alternatives: ["Step-back burpee", "Squat thrust", "Mountain climber"]
        )),
        Entry(patterns: ["box jump"], guide: MovementGuide(
            whatIsIt: "An explosive jump onto a box to build lower-body power.",
            howTo: [
                "Stand a short step from the box, feet hip-width.",
                "Load by hinging and swinging arms back, then jump onto the box.",
                "Land softly with knees bent, stand tall, and step down."
            ],
            alternatives: ["Step-up", "Broad jump", "Squat jump"]
        )),
        Entry(patterns: ["step-up", "step up"], guide: MovementGuide(
            whatIsIt: "A single-leg strength movement using a box or bench.",
            howTo: [
                "Place one foot fully on the box with knee over foot.",
                "Drive through the heel to stand tall on the box.",
                "Step down under control with the same leg."
            ],
            alternatives: ["Reverse lunge", "Bulgarian split squat", "Goblet squat"]
        )),
        Entry(patterns: ["shuffle"], guide: MovementGuide(
            whatIsIt: "Lateral agility drill for footwork and conditioning.",
            howTo: [
                "Set an athletic stance with hips low.",
                "Push off the outside foot and stay low as you move sideways.",
                "Keep chest up and feet quick — don't cross over."
            ],
            alternatives: ["Lateral band walk", "Ladder drills", "Cone drills"]
        )),
        Entry(patterns: ["bear crawl", "sled"], guide: MovementGuide(
            whatIsIt: "Ground-based crawling or dragging for conditioning and core strength.",
            howTo: [
                "Hands and feet on the ground with knees hovering.",
                "Move opposite hand and foot together in small steps.",
                "Stay low and keep hips from rocking."
            ],
            alternatives: ["Crab walk", "Farmer carry", "Sled push"]
        )),
        Entry(patterns: ["calf raise"], guide: MovementGuide(
            whatIsIt: "An isolation movement for the calves.",
            howTo: [
                "Stand tall on a slightly elevated surface.",
                "Press up through the balls of your feet to full extension.",
                "Lower slowly below neutral for a full stretch."
            ],
            alternatives: ["Seated calf raise", "Jump rope", "Donkey calf raise"]
        )),
        Entry(patterns: ["rest"], guide: MovementGuide(
            whatIsIt: "Programmed recovery between efforts.",
            howTo: [
                "Stop moving and breathe deeply.",
                "Walk slowly or stand still — don't sit if you're very warm.",
                "Start the next effort on the clock."
            ],
            alternatives: ["Easy walk", "Light stretch", "Breathing practice"]
        ))
    ]
}

enum CardioGuideLibrary {

    static func guide(for workout: CardioWorkoutDefinition) -> MovementGuide {
        let key = workout.name.lowercased()
        for entry in entries {
            if entry.patterns.contains(where: { key.contains($0) }) {
                return entry.guide
            }
        }
        return MovementGuideLibrary.guide(for: workout.name)
    }

    static func hasGuide(for name: String) -> Bool {
        let key = name.lowercased()
        return entries.contains(where: { entry in entry.patterns.contains(where: { key.contains($0) }) })
    }

    private struct Entry {
        let patterns: [String]
        let guide: MovementGuide
    }

    private static let entries: [Entry] = [
        Entry(patterns: ["outdoor run"], guide: MovementGuide(
            whatIsIt: "Steady-state outdoor running at a conversational-to-moderate effort.",
            howTo: [
                "Warm up with 3–5 minutes of easy jogging or walking.",
                "Run tall with a quick, light cadence and relaxed shoulders.",
                "Finish with a short cool-down walk and light stretching."
            ],
            alternatives: ["Treadmill run", "Elliptical", "Brisk outdoor walk"]
        )),
        Entry(patterns: ["treadmill"], guide: MovementGuide(
            whatIsIt: "Indoor run on a treadmill with controlled speed and incline.",
            howTo: [
                "Start with a 5-minute warm-up walk at a low incline.",
                "Build to your target pace and keep shoulders relaxed.",
                "Cool down at a walking pace before stepping off."
            ],
            alternatives: ["Outdoor run", "Elliptical", "Stair climber"]
        )),
        Entry(patterns: ["sprint"], guide: MovementGuide(
            whatIsIt: "Short, near-maximal running efforts with full recovery between.",
            howTo: [
                "Warm up thoroughly with easy running and dynamic drills.",
                "Sprint all-out for the prescribed distance or time.",
                "Walk or stand to fully recover before the next effort."
            ],
            alternatives: ["Hill sprints", "Assault bike sprints", "Rower sprints"]
        )),
        Entry(patterns: ["interval"], guide: MovementGuide(
            whatIsIt: "Alternating fast and easy segments to build speed and aerobic fitness.",
            howTo: [
                "Warm up 5–10 minutes at an easy pace.",
                "Alternate hard effort and recovery for the prescribed intervals.",
                "Cool down 5 minutes at an easy pace."
            ],
            alternatives: ["Fartlek run", "Bike intervals", "Rower intervals"]
        )),
        Entry(patterns: ["fartlek"], guide: MovementGuide(
            whatIsIt: "Unstructured speed play — vary pace by feel throughout the run.",
            howTo: [
                "Warm up with 5 minutes easy.",
                "Surge at random points (landmarks, songs, breath counts).",
                "Return to easy pace between surges."
            ],
            alternatives: ["Structured intervals", "Tempo run", "Bike fartlek"]
        )),
        Entry(patterns: ["tempo"], guide: MovementGuide(
            whatIsIt: "Sustained effort at a comfortably hard pace to raise lactate threshold.",
            howTo: [
                "Warm up 10 minutes at an easy pace.",
                "Run the tempo portion at an effort you could hold for about an hour.",
                "Finish with 5–10 minutes of easy cool-down."
            ],
            alternatives: ["Progression run", "Threshold intervals", "Bike tempo"]
        )),
        Entry(patterns: ["long run"], guide: MovementGuide(
            whatIsIt: "An extended easy-pace run to build aerobic endurance.",
            howTo: [
                "Go out slower than race pace — you should be able to talk.",
                "Hydrate and fuel on longer efforts.",
                "Finish steady, not exhausted."
            ],
            alternatives: ["Long bike ride", "Long hike", "Long rowing session"]
        )),
        Entry(patterns: ["hill"], guide: MovementGuide(
            whatIsIt: "Repeated uphill efforts to build power, strength, and running form.",
            howTo: [
                "Warm up 10 minutes on flat ground.",
                "Drive hard up the hill with a strong arm swing.",
                "Recover by jogging or walking down, then repeat."
            ],
            alternatives: ["Stair running", "Treadmill incline", "Bike hill climbs"]
        )),
        Entry(patterns: ["track"], guide: MovementGuide(
            whatIsIt: "Structured intervals on a track — 200s, 400s, 800s, or mile repeats.",
            howTo: [
                "Warm up 1 mile easy plus drills.",
                "Run each rep at the prescribed pace with equal-distance jog recovery.",
                "Cool down 1 mile easy."
            ],
            alternatives: ["Treadmill intervals", "Road intervals", "Bike intervals"]
        )),
        Entry(patterns: ["recovery run", "easy recovery"], guide: MovementGuide(
            whatIsIt: "A light jog at conversational pace for active recovery.",
            howTo: [
                "Keep effort truly easy — nose breathing should be possible.",
                "Focus on smooth, relaxed form.",
                "Stop if pace creeps up; this should feel restorative."
            ],
            alternatives: ["Easy walk", "Elliptical", "Gentle bike spin"]
        )),
        Entry(patterns: ["couch to 5k"], guide: MovementGuide(
            whatIsIt: "Walk/run intervals for beginners building up to a 5K.",
            howTo: [
                "Start with short run intervals (e.g. 60s) separated by walking.",
                "Progress run time each week as you feel stronger.",
                "Stay consistent 3 days a week."
            ],
            alternatives: ["Walk/jog intervals", "Elliptical intervals", "Bike intervals"]
        )),

        // Cycling
        Entry(patterns: ["outdoor bike"], guide: MovementGuide(
            whatIsIt: "Road or trail cycling at your chosen pace.",
            howTo: [
                "Wear a helmet and check tire pressure and brakes.",
                "Warm up with an easy spin for 5–10 minutes.",
                "Maintain a steady cadence and shift gears as terrain changes."
            ],
            alternatives: ["Indoor bike", "Spin class", "Elliptical"]
        )),
        Entry(patterns: ["indoor bike"], guide: MovementGuide(
            whatIsIt: "Stationary bike session with adjustable resistance.",
            howTo: [
                "Set saddle so your knee is slightly bent at the bottom of the pedal stroke.",
                "Warm up easy, then raise resistance or cadence to the target effort.",
                "Cool down with easy spinning for 3–5 minutes."
            ],
            alternatives: ["Outdoor bike", "Spin class", "Rowing machine"]
        )),
        Entry(patterns: ["spin"], guide: MovementGuide(
            whatIsIt: "High-energy indoor cycling class with intervals and climbs.",
            howTo: [
                "Dial in saddle height and handlebar position before class.",
                "Follow the instructor's cadence and resistance cues.",
                "Cool down with easy spinning and a brief stretch."
            ],
            alternatives: ["Solo indoor bike intervals", "Outdoor hills", "Cycling intervals"]
        )),

        // Classes
        Entry(patterns: ["yoga"], guide: MovementGuide(
            whatIsIt: "Flow through poses for flexibility, balance, and mindfulness.",
            howTo: [
                "Start with a few minutes of easy breathing to settle in.",
                "Move with the breath — slow, deliberate transitions.",
                "Finish with a short rest pose to absorb the work."
            ],
            alternatives: ["Stretching routine", "Pilates", "Tai chi"]
        )),
        Entry(patterns: ["pilates"], guide: MovementGuide(
            whatIsIt: "Core-focused mat or reformer exercises for stability and tone.",
            howTo: [
                "Warm up with mobility for the spine and hips.",
                "Focus on slow, controlled reps with steady breathing.",
                "Stretch briefly at the end."
            ],
            alternatives: ["Yoga", "Core circuit", "Barre"]
        )),
        Entry(patterns: ["zumba", "dance"], guide: MovementGuide(
            whatIsIt: "Dance-based cardio blending fun choreography with steady movement.",
            howTo: [
                "Wear supportive shoes and give yourself room.",
                "Follow the instructor or playlist — modify intensity as needed.",
                "Cool down with a slow song and light stretch."
            ],
            alternatives: ["Aerobics", "Kickboxing", "Step aerobics"]
        )),
        Entry(patterns: ["aerobics"], guide: MovementGuide(
            whatIsIt: "Classic group cardio with choreographed movements.",
            howTo: [
                "Warm up with light marching and arm swings.",
                "Follow the routine, keeping knees soft and core engaged.",
                "Cool down and stretch major muscle groups."
            ],
            alternatives: ["Zumba", "Step aerobics", "Dance cardio"]
        )),
        Entry(patterns: ["barre"], guide: MovementGuide(
            whatIsIt: "Ballet-inspired workout targeting small stabilizing muscles.",
            howTo: [
                "Use a chair or countertop if there's no barre.",
                "Perform small, controlled pulses with proper alignment.",
                "Stretch the worked muscles between sections."
            ],
            alternatives: ["Pilates", "Yoga", "Glute band circuit"]
        )),
        Entry(patterns: ["kickboxing", "boxing"], guide: MovementGuide(
            whatIsIt: "Martial-arts-inspired cardio combining punches, kicks, and footwork.",
            howTo: [
                "Warm up shoulders, hips, and core thoroughly.",
                "Keep hands up and exhale sharply on each strike.",
                "Alternate striking rounds with active recovery."
            ],
            alternatives: ["Shadow boxing", "Heavy bag", "HIIT circuit"]
        )),

        // Low impact
        Entry(patterns: ["walking", "power walk"], guide: MovementGuide(
            whatIsIt: "Brisk walking for heart health and active recovery.",
            howTo: [
                "Stand tall with relaxed shoulders and a natural arm swing.",
                "Walk at a pace where talking is easy but singing isn't.",
                "Add small inclines or hills for variety."
            ],
            alternatives: ["Treadmill incline walk", "Elliptical", "Easy hike"]
        )),
        Entry(patterns: ["swim"], guide: MovementGuide(
            whatIsIt: "Full-body low-impact pool workout.",
            howTo: [
                "Warm up with 100–200m of easy swimming.",
                "Alternate strokes or do intervals with short rests.",
                "Cool down with easy laps and a quick stretch on deck."
            ],
            alternatives: ["Water aerobics", "Elliptical", "Rowing"]
        )),
        Entry(patterns: ["rowing"], guide: MovementGuide(
            whatIsIt: "Full-body pull on the erg — strong legs, hinge, then arms.",
            howTo: [
                "Legs drive first, then hinge hips, then pull handle to lower ribs.",
                "Reverse in order: arms out, hips over, knees bend.",
                "Aim for a steady stroke rate of 22–28 for endurance."
            ],
            alternatives: ["SkiErg", "Cycling", "Swimming"]
        )),
        Entry(patterns: ["elliptical"], guide: MovementGuide(
            whatIsIt: "Low-impact machine that mimics running without joint stress.",
            howTo: [
                "Stand tall with light grip on the handles.",
                "Drive through the whole foot — don't tip-toe.",
                "Mix resistance and incline for variety."
            ],
            alternatives: ["Stationary bike", "Treadmill walk", "Stair climber"]
        )),
        Entry(patterns: ["stair climber", "stair"], guide: MovementGuide(
            whatIsIt: "Continuous stair climbing for leg and glute conditioning.",
            howTo: [
                "Stand tall — don't lean on the handles.",
                "Place whole foot on each step and drive through the heel.",
                "Pick a steady pace you can hold for the full session."
            ],
            alternatives: ["Incline treadmill", "Stair running", "Step-ups"]
        )),
        Entry(patterns: ["stretch", "mobility"], guide: MovementGuide(
            whatIsIt: "Guided stretching routine for flexibility and recovery.",
            howTo: [
                "Start with light movement to warm tissues.",
                "Hold each stretch 20–60 seconds, breathing deeply.",
                "Never stretch to sharp pain — ease into the tension."
            ],
            alternatives: ["Yoga flow", "Foam rolling", "Tai chi"]
        )),
        Entry(patterns: ["tai chi"], guide: MovementGuide(
            whatIsIt: "Slow, flowing movements for balance, calm, and joint health.",
            howTo: [
                "Stand tall with knees soft and weight evenly distributed.",
                "Move slowly and continuously, syncing breath with motion.",
                "Keep the pace unhurried throughout."
            ],
            alternatives: ["Yoga", "Mobility flow", "Walking meditation"]
        )),

        // Outdoor
        Entry(patterns: ["hiking", "hike"], guide: MovementGuide(
            whatIsIt: "Trail hiking for endurance, scenery, and fresh air.",
            howTo: [
                "Wear supportive shoes and carry water.",
                "Take shorter steps on steep sections and brace your core.",
                "Pace yourself — finish feeling strong, not wrecked."
            ],
            alternatives: ["Incline treadmill walk", "Rucking", "Long walk"]
        )),
        Entry(patterns: ["trail run"], guide: MovementGuide(
            whatIsIt: "Off-road running on trails for a varied-terrain challenge.",
            howTo: [
                "Shorten stride on technical ground and watch your footing.",
                "Use arms for balance on descents.",
                "Hike steep climbs — don't grind yourself into the ground."
            ],
            alternatives: ["Road run", "Treadmill with incline", "Hiking"]
        )),
        Entry(patterns: ["rucking", "ruck"], guide: MovementGuide(
            whatIsIt: "Walking with a weighted backpack for strength endurance.",
            howTo: [
                "Start light — 10–20 lb — and keep the load high on your back.",
                "Stand tall with an even stride.",
                "Build distance before you add weight."
            ],
            alternatives: ["Weighted vest walk", "Incline treadmill", "Hiking"]
        )),
        Entry(patterns: ["stair running"], guide: MovementGuide(
            whatIsIt: "Running stadium or building stairs for explosive leg power.",
            howTo: [
                "Warm up 5–10 minutes of easy jogging first.",
                "Drive hard going up, walk back down to recover.",
                "Stop if form breaks down — quality over quantity."
            ],
            alternatives: ["Hill sprints", "Stair climber", "Box step-ups"]
        )),
        Entry(patterns: ["boot camp"], guide: MovementGuide(
            whatIsIt: "Outdoor circuit training mixing cardio and strength moves.",
            howTo: [
                "Warm up with dynamic movements and light jogging.",
                "Rotate through stations with short rests.",
                "Finish with a cool-down walk and mobility."
            ],
            alternatives: ["HIIT circuit", "Functional fitness class", "Park workout"]
        )),
        Entry(patterns: ["beach run"], guide: MovementGuide(
            whatIsIt: "Sand running for extra resistance and ankle stability.",
            howTo: [
                "Start on firmer wet sand, which is easier on joints.",
                "Shorten your stride; sand will shorten it for you anyway.",
                "Run shorter than you would on road — it's deceptively tough."
            ],
            alternatives: ["Trail run", "Hill repeats", "Grass run"]
        ))
    ]
}
