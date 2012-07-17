<?php
/**
Copyright 2012 Nick Korbel

This file is part of phpScheduleIt.

phpScheduleIt is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

phpScheduleIt is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with phpScheduleIt.  If not, see <http://www.gnu.org/licenses/>.
 */

require_once(ROOT_DIR . 'Domain/Access/namespace.php');
require_once(ROOT_DIR . 'Domain/Access/ReportCommandBuilder.php');
require_once(ROOT_DIR . 'Domain/SavedReport.php');

interface IReportingRepository
{
	/**
	 * @abstract
	 * @param ReportCommandBuilder $commandBuilder
	 * @return array
	 */
	public function GetCustomReport(ReportCommandBuilder $commandBuilder);

	/**
	 * @abstract
	 * @param SavedReport $savedReport
	 */
	public function SaveCustomReport(SavedReport $savedReport);

	/**
	 * @abstract
	 * @param int $userId
	 * @return array|SavedReport[]
	 */
	public function LoadSavedReportsForUser($userId);

	/**
	 * @abstract
	 * @param int $reportId
	 * @param int $userId
	 * @return SavedReport
	 */
	public function LoadSavedReportForUser($reportId, $userId);
}

class ReportingRepository implements IReportingRepository
{
	/**
	 * @param ReportCommandBuilder $commandBuilder
	 * @return array
	 */
	public function GetCustomReport(ReportCommandBuilder $commandBuilder)
	{
		$reader = ServiceLocator::GetDatabase()->Query($commandBuilder->Build());
		$rows = array();
		while ($row = $reader->GetRow())
		{
			$rows[] = $row;
		}
		$reader->Free();

		return $rows;
	}

	public function SaveCustomReport(SavedReport $report)
	{
		$serialized = ReportSerializer::Serialize($report);
		ServiceLocator::GetDatabase()->ExecuteInsert(new AddSavedReportCommand($report->ReportName(), $report->OwnerId(), $report->DateCreated(), $serialized));
	}

	/**
	 * @param $userId
	 * @return array|SavedReport[]
	 */
	public function LoadSavedReportsForUser($userId)
	{
		$reader = ServiceLocator::GetDatabase()->Query(new GetAllSavedReportsForUserCommand($userId));
		$reports = array();
		while ($row = $reader->GetRow())
		{
			$reports[] = SavedReport::FromDatabase(
				$row[ColumnNames::REPORT_NAME],
				$row[ColumnNames::USER_ID],
				Date::FromDatabase($row[ColumnNames::DATE_CREATED]),
				$row[ColumnNames::REPORT_DETAILS],
				$row[ColumnNames::REPORT_ID]
			);
		}
		$reader->Free();

		return $reports;
	}

	/**
	 * @param int $reportId
	 * @param int $userId
	 * @return SavedReport
	 */
	public function LoadSavedReportForUser($reportId, $userId)
	{
		$reader = ServiceLocator::GetDatabase()->Query(new GetSavedReportForUserCommand($reportId, $userId));

		if ($row = $reader->GetRow())
		{
			return SavedReport::FromDatabase(
				$row[ColumnNames::REPORT_NAME],
				$row[ColumnNames::USER_ID],
				Date::FromDatabase($row[ColumnNames::DATE_CREATED]),
				$row[ColumnNames::REPORT_DETAILS],
				$row[ColumnNames::REPORT_ID]
			);
		}
		else
		{
			return null;
		}
	}
}

?>