import { Link, Form } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import { Field, FieldError } from "@/components/ui/field"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { ArrowLeft } from "lucide-react"
import { useBreadcrumbs } from "@/hooks/use-breadcrumbs"

interface SelectOption {
  value: string
  label: string
}

interface Project {
  id: number
  name: string
  description: string | null
  project_type: string
  status: string
  address: string | null
  city: string | null
  state: string | null
  zip_code: string | null
  budget: number | null
  start_date: string | null
  estimated_completion_date: string | null
}

interface Props {
  project: Project
  project_types: SelectOption[]
  statuses: SelectOption[]
}

export default function ProjectsEdit({ project, project_types, statuses }: Props) {
  useBreadcrumbs([
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'Projects', href: '/projects' },
    { label: project.name, href: `/projects/${project.id}` },
    { label: 'Edit' }
  ])

  return (
    <div className="container max-w-3xl mx-auto py-8 px-4">
      <div className="mb-8">
        <Link href={`/projects/${project.id}`} className="inline-flex items-center text-sm text-muted-foreground hover:text-foreground mb-2">
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back to Project
        </Link>
        <h1 className="text-3xl font-bold">Edit Project</h1>
        <p className="text-muted-foreground mt-2">
          Update project information
        </p>
      </div>

      <Form action={`/projects/${project.id}`} method="patch">
        {({ processing, errors }) => (
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Basic Information</CardTitle>
                <CardDescription>
                  Update the project details
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <Field data-invalid={!!errors.name}>
                  <Label htmlFor="name">Project Name *</Label>
                  <Input
                    id="name"
                    name="name"
                    defaultValue={project.name}
                    placeholder="e.g., Sunset Villa Construction"
                    aria-invalid={!!errors.name}
                    required
                  />
                  {errors.name && (
                    <FieldError>{errors.name}</FieldError>
                  )}
                </Field>

                <Field data-invalid={!!errors.description}>
                  <Label htmlFor="description">Description</Label>
                  <Textarea
                    id="description"
                    name="description"
                    defaultValue={project.description || ''}
                    placeholder="Provide a detailed description of the project..."
                    rows={4}
                    aria-invalid={!!errors.description}
                  />
                  {errors.description && (
                    <FieldError>{errors.description}</FieldError>
                  )}
                </Field>

                <div className="grid gap-4 md:grid-cols-2">
                  <Field data-invalid={!!errors.project_type}>
                    <Label htmlFor="project_type">Project Type *</Label>
                    <Select name="project_type" defaultValue={project.project_type} required>
                      <SelectTrigger id="project_type" aria-invalid={!!errors.project_type}>
                        <SelectValue placeholder="Select type" />
                      </SelectTrigger>
                      <SelectContent>
                        {project_types.map((type) => (
                          <SelectItem key={type.value} value={type.value}>
                            {type.value === 'new_build' ? '🏗️' : '🔨'} {type.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    {errors.project_type && (
                      <FieldError>{errors.project_type}</FieldError>
                    )}
                  </Field>

                  <Field data-invalid={!!errors.status}>
                    <Label htmlFor="status">Status *</Label>
                    <Select name="status" defaultValue={project.status} required>
                      <SelectTrigger id="status" aria-invalid={!!errors.status}>
                        <SelectValue placeholder="Select status" />
                      </SelectTrigger>
                      <SelectContent>
                        {statuses.map((status) => (
                          <SelectItem key={status.value} value={status.value}>
                            {status.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    {errors.status && (
                      <FieldError>{errors.status}</FieldError>
                    )}
                  </Field>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Location</CardTitle>
                <CardDescription>
                  Where is this project located?
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <Field data-invalid={!!errors.address}>
                  <Label htmlFor="address">Street Address</Label>
                  <Input
                    id="address"
                    name="address"
                    defaultValue={project.address || ''}
                    placeholder="123 Main Street"
                    aria-invalid={!!errors.address}
                  />
                  {errors.address && (
                    <FieldError>{errors.address}</FieldError>
                  )}
                </Field>

                <div className="grid gap-4 md:grid-cols-3">
                  <Field data-invalid={!!errors.city}>
                    <Label htmlFor="city">City</Label>
                    <Input
                      id="city"
                      name="city"
                      defaultValue={project.city || ''}
                      placeholder="San Francisco"
                      aria-invalid={!!errors.city}
                    />
                    {errors.city && (
                      <FieldError>{errors.city}</FieldError>
                    )}
                  </Field>

                  <Field data-invalid={!!errors.state}>
                    <Label htmlFor="state">State</Label>
                    <Input
                      id="state"
                      name="state"
                      defaultValue={project.state || ''}
                      placeholder="CA"
                      maxLength={2}
                      aria-invalid={!!errors.state}
                    />
                    {errors.state && (
                      <FieldError>{errors.state}</FieldError>
                    )}
                  </Field>

                  <Field data-invalid={!!errors.zip_code}>
                    <Label htmlFor="zip_code">ZIP Code</Label>
                    <Input
                      id="zip_code"
                      name="zip_code"
                      defaultValue={project.zip_code || ''}
                      placeholder="94105"
                      aria-invalid={!!errors.zip_code}
                    />
                    {errors.zip_code && (
                      <FieldError>{errors.zip_code}</FieldError>
                    )}
                  </Field>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Timeline & Budget</CardTitle>
                <CardDescription>
                  Set project timeline and budget information
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid gap-4 md:grid-cols-2">
                  <Field data-invalid={!!errors.start_date}>
                    <Label htmlFor="start_date">Start Date</Label>
                    <Input
                      id="start_date"
                      name="start_date"
                      type="date"
                      defaultValue={project.start_date || ''}
                      aria-invalid={!!errors.start_date}
                    />
                    {errors.start_date && (
                      <FieldError>{errors.start_date}</FieldError>
                    )}
                  </Field>

                  <Field data-invalid={!!errors.estimated_completion_date}>
                    <Label htmlFor="estimated_completion_date">Estimated Completion</Label>
                    <Input
                      id="estimated_completion_date"
                      name="estimated_completion_date"
                      type="date"
                      defaultValue={project.estimated_completion_date || ''}
                      aria-invalid={!!errors.estimated_completion_date}
                    />
                    {errors.estimated_completion_date && (
                      <FieldError>{errors.estimated_completion_date}</FieldError>
                    )}
                  </Field>
                </div>

                <Field data-invalid={!!errors.budget}>
                  <Label htmlFor="budget">Budget ($)</Label>
                  <Input
                    id="budget"
                    name="budget"
                    type="number"
                    step="0.01"
                    min="0"
                    defaultValue={project.budget || ''}
                    placeholder="0.00"
                    aria-invalid={!!errors.budget}
                  />
                  {errors.budget && (
                    <FieldError>{errors.budget}</FieldError>
                  )}
                </Field>
              </CardContent>
            </Card>

            <div className="flex justify-end gap-2">
              <Link href={`/projects/${project.id}`}>
                <Button type="button" variant="outline">
                  Cancel
                </Button>
              </Link>
              <Button type="submit" disabled={processing}>
                {processing ? 'Saving...' : 'Save Changes'}
              </Button>
            </div>
          </div>
        )}
      </Form>
    </div>
  )
}