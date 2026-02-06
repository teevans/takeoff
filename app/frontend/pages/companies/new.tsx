import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import {
  Field,
  FieldDescription,
  FieldError,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { Spinner } from "@/components/ui/spinner"
import { Form, Link } from "@inertiajs/react"
import { ArrowLeft } from "lucide-react"
import { useBreadcrumbs } from "@/hooks/use-breadcrumbs"

export default function CompaniesNew() {
  useBreadcrumbs([
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'Companies', href: '/companies' },
    { label: 'New Company' }
  ])
  return (
    <div className="container max-w-2xl mx-auto py-8 px-4">
      <Link href="/companies" className="inline-flex items-center text-sm text-muted-foreground hover:text-foreground mb-6">
        <ArrowLeft className="mr-2 h-4 w-4" />
        Back to companies
      </Link>
      
      <Card>
        <CardHeader>
          <CardTitle>Create a new company</CardTitle>
          <CardDescription>
            Set up a new company to collaborate with your team
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Form action="/companies" method="post">
            {({ processing, errors }) => (
              <FieldGroup>
                <Field data-invalid={!!errors.name}>
                  <FieldLabel htmlFor="name">Company Name</FieldLabel>
                  <Input
                    id="name"
                    name="name"
                    type="text"
                    placeholder="Acme Inc."
                    aria-invalid={!!errors.name}
                    required
                  />
                  <FieldDescription>
                    This will be visible to all team members
                  </FieldDescription>
                  {errors.name && (
                    <FieldError>{errors.name}</FieldError>
                  )}
                </Field>
                
                <div className="flex gap-4">
                  <Button type="submit" disabled={processing}>
                    {processing && <Spinner />}
                    Create Company
                  </Button>
                  <Link href="/companies">
                    <Button type="button" variant="outline">
                      Cancel
                    </Button>
                  </Link>
                </div>
              </FieldGroup>
            )}
          </Form>
        </CardContent>
      </Card>
    </div>
  )
}