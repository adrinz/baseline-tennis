import lessons from "@/data/lessons.json";

export type LessonStatus = "draft" | "published";

export type Lesson = {
  slug: string;
  title: string;
  level: number;
  levelName: string;
  category: string;
  status: LessonStatus;
};

function isLessonStatus(value: string): value is LessonStatus {
  return value === "draft" || value === "published";
}

export const lessonCatalog: Lesson[] = lessons.map((lesson) => {
  if (!isLessonStatus(lesson.status)) {
    throw new Error(`Unknown lesson status for ${lesson.slug}`);
  }
  return {
    slug: lesson.slug,
    title: lesson.title,
    level: lesson.level,
    levelName: lesson.levelName,
    category: lesson.category,
    status: lesson.status,
  };
});
