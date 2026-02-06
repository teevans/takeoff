import { AppSidebar } from "@/components/app-sidebar"
import {
    Breadcrumb,
    BreadcrumbItem,
    BreadcrumbLink,
    BreadcrumbList,
    BreadcrumbPage,
    BreadcrumbSeparator,
} from "@/components/ui/breadcrumb"
import { Separator } from "@/components/ui/separator"
import {
    SidebarInset,
    SidebarProvider,
    SidebarTrigger,
} from "@/components/ui/sidebar"
import { BreadcrumbProvider, useBreadcrumbContext } from "@/contexts/breadcrumb-context"
import { Link, usePage } from "@inertiajs/react"
import React from "react"
import { CompanySwitcher } from "@/components/company-switcher"

interface PageProps {
    auth?: {
        user?: {
            companies?: Array<{
                id: number
                name: string
                role: string
            }>
            current_company_id?: number
        }
    }
    [key: string]: any
}

function LayoutContent({children}: {children: React.ReactNode}) {
    const { breadcrumbs } = useBreadcrumbContext()
    const { props } = usePage<PageProps>()
    const companies = props.auth?.user?.companies || []
    const currentCompanyId = props.auth?.user?.current_company_id
    
    // Debug logging
    console.log('Auth props:', props.auth)
    console.log('Companies:', companies)
    console.log('Current Company ID:', currentCompanyId)
    
    return (
        <SidebarProvider>
            <AppSidebar />
            <SidebarInset>
                <header className="flex h-16 shrink-0 items-center gap-2 border-b">
                    <div className="flex items-center justify-between w-full px-4">
                        <div className="flex items-center gap-2">
                            <SidebarTrigger className="-ml-1" />
                            {breadcrumbs.length > 0 && (
                                <>
                                    <Separator
                                        orientation="vertical"
                                        className="mr-2"
                                    />
                                    <Breadcrumb>
                                        <BreadcrumbList>
                                            {breadcrumbs.map((crumb, index) => (
                                                <React.Fragment key={index}>
                                                    {index > 0 && <BreadcrumbSeparator />}
                                                    <BreadcrumbItem>
                                                        {crumb.href && index < breadcrumbs.length - 1 ? (
                                                            <BreadcrumbLink asChild>
                                                                <Link prefetch href={crumb.href}>{crumb.label}</Link>
                                                            </BreadcrumbLink>
                                                        ) : (
                                                            <BreadcrumbPage>{crumb.label}</BreadcrumbPage>
                                                        )}
                                                    </BreadcrumbItem>
                                                </React.Fragment>
                                            ))}
                                        </BreadcrumbList>
                                    </Breadcrumb>
                                </>
                            )}
                        </div>
                        <CompanySwitcher 
                            companies={companies}
                            currentCompanyId={currentCompanyId}
                            className="w-[200px]"
                        />
                    </div>
                </header>
                <div className="flex flex-1 flex-col gap-4 p-4 pt-0">
                    {children}
                </div>
            </SidebarInset>
        </SidebarProvider>
    )
}

export default function Layout({children}: {children: React.ReactNode}) {
    return (
        <BreadcrumbProvider>
            <LayoutContent>{children}</LayoutContent>
        </BreadcrumbProvider>
    )
}

